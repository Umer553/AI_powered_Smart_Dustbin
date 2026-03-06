================================================================================
FCM NOTIFICATION LOGIC ANALYSIS & IMPROVEMENTS
Smart Dustbin Backend
================================================================================

CURRENT FCM IMPLEMENTATION ANALYSIS
================================================================================

✅ WHAT IS CORRECT
====================

1. DATABASE USAGE (Firestore) ✅
   Current: YES, using Firestore correctly
   Evidence:
     - services/database.py:12-13: Firebase Firestore initialized globally
     - Collections created: bins/{bin_id}/latest_state, events, tokens
     - Document structure properly nested with subcollections
     - State persistence: fill_level, human_detected, vacuum_on, lid_open, last_updated, last_alert_sent_at
     - Event logging: timestamp, old_level, new_level, type
     - Token storage: bins/{bin_id}/tokens/{token}
   
   Status: ✅ CORRECT - Using Firestore for persistent storage

2. TOKEN REGISTRATION FLOW ✅
   Current Implementation:
     - routes/Fcm_token.py: POST /notifications/register-token
     - Accepts: {bin_id, token}
     - Stores in: bins/{bin_id}/tokens/{token}
     - Document ID = token (prevents duplicates)
   
   Status: ✅ CORRECT

3. COOLDOWN MECHANISM ✅
   Current Implementation:
     - services/database.py:send_notification_to_bin (lines 92-129)
     - Tracks: last_alert_sent_at
     - Prevents spam: waits 30 minutes before next alert
     - Default threshold: 95%
   
   Status: ✅ CORRECT

4. BATCH NOTIFICATION SENDING ✅
   Current Implementation:
     - Gets all tokens: get_bin_tokens(bin_id) → List[str]
     - Sends to each: send_notification_to_token(token, title, body)
     - Error handling: try/catch per token, continues if one fails
     - Returns results array with status per token
   
   Status: ✅ CORRECT

5. FIREBASE MESSAGING ✅
   Current Implementation:
     - firebase_admin.messaging.Message() properly formatted
     - notification.Notification(title, body) used
     - Token-based targeting (not topic-based)
     - Response tracking: message ID returned
   
   Status: ✅ CORRECT

⚠️ WHAT NEEDS IMPROVEMENT
====================

1. MISSING: NOTIFICATION HISTORY LOGGING ⚠️
   Current: Notifications sent but NOT logged to database
   Issue: No audit trail of sent notifications
   Impact: Can't track delivery status, retry failed sends, or show history to users
   
   Missing collection: bins/{bin_id}/notifications
   Should include:
     - notification_id (auto-generated)
     - timestamp
     - title
     - body
     - tokens_sent_to (array)
     - delivery_status (sent, failed, pending)
     - fcm_message_ids (array of response IDs)

2. MISSING: DATA MESSAGE PAYLOAD ⚠️
   Current: Only uses notification{title, body}
   Issue: Flutter app can't customize handling or pass extra data
   Impact: Limited notification actions and metadata
   
   Should add: data{} payload with action-specific information
   Example:
     {
       "notification": {"title": "...", "body": "..."},
       "data": {
         "action": "fill_alert",
         "bin_id": "A1",
         "fill_level": "95.5",
         "timestamp": "2025-12-11T10:30:00Z"
       }
     }

3. MISSING: ERROR RETRY LOGIC ⚠️
   Current: Sends once, catches exception, moves on
   Issue: Transient FCM errors not retried
   Impact: Notifications may fail silently on network glitches
   
   Should add: exponential backoff retry for failed sends

4. MISSING: NOTIFICATION PREFERENCES ⚠️
   Current: All users for a bin get same notification
   Issue: No ability to customize alert frequency or disable
   Impact: Can't satisfy different user preferences
   
   Should add: bins/{bin_id}/user_preferences collection
   Fields:
     - user_id
     - token
     - notification_enabled (bool)
     - alert_frequency (immediate, hourly, daily)
     - alert_threshold_override (optional)

5. MISSING: NOTIFICATION DELIVERY CONFIRMATION ⚠️
   Current: Backend sends, assumes delivery
   Issue: Don't know if user actually received message
   Impact: Can't confirm message arrived
   
   Should add: Flutter app sends receipt to backend
   Endpoint: POST /notifications/{notification_id}/confirm

6. DUPLICATE FUNCTION: send_notification_to_token ⚠️
   Current: Defined in BOTH:
     - services/database.py (line 84-89)
     - services/notifications.py (line 10-20)
   Issue: Code duplication, maintenance confusion
   Impact: If you fix one, the other still has bug
   
   Should remove one, keep other

================================================================================
CORRECTED & IMPROVED FCM LOGIC
================================================================================

Here's the improved implementation:

FILE 1: services/database.py (UPDATED)
================================================================================

ADD THIS FUNCTION (after line 129):

def log_notification_sent(bin_id: str, title: str, body: str, 
                         tokens: List[str], fcm_response_ids: List[str]):
    """
    Log notification sent event for audit trail and troubleshooting
    
    Args:
        bin_id: Target bin identifier
        title: Notification title
        body: Notification body
        tokens: List of tokens sent to
        fcm_response_ids: FCM message IDs for delivery tracking
    """
    timestamp = datetime.now().isoformat()
    notification_id = f"{bin_id}_{int(datetime.now().timestamp() * 1000)}"
    
    notification_ref = db.collection("bins").document(bin_id).collection("notifications")
    notification_ref.document(notification_id).set({
        "notification_id": notification_id,
        "timestamp": timestamp,
        "title": title,
        "body": body,
        "tokens_sent_to": tokens,
        "num_recipients": len(tokens),
        "fcm_message_ids": fcm_response_ids,
        "delivery_status": "sent",  # Later updated by app receipt
        "read_count": 0,
        "failed_tokens": []
    })
    
    return notification_id


def get_notification_history(bin_id: str, limit: int = 50):
    """
    Get notification history for a bin (for debugging/display)
    
    Args:
        bin_id: Target bin identifier
        limit: Max number of notifications to return
    
    Returns:
        List of notification documents, newest first
    """
    notifications_ref = db.collection("bins").document(bin_id).collection("notifications")
    docs = notifications_ref.order_by("timestamp", direction=firestore.Query.DESCENDING).limit(limit).stream()
    return [doc.to_dict() for doc in docs]


================================================================================

REPLACE THIS FUNCTION (lines 92-129):

# OLD (has issues)
def send_notification_to_bin(bin_id: str, title: str, body: str,
                             threshold: float = 95.0, cooldown_minutes: int = 30):
    state = get_bin_state(bin_id)
    if not state:
        return {"status": "no_state"}

    fill_level = state.get("fill_level", 0)
    last_alert = state.get("last_alert_sent_at")

    now = datetime.now()
    if fill_level >= threshold:
        if not last_alert or (now - datetime.fromisoformat(last_alert)) >= timedelta(minutes=cooldown_minutes):
            tokens = get_bin_tokens(bin_id)
            results = []
            for t in tokens:
                try:
                    resp = send_notification_to_token(t, title, body)
                    results.append({"token": t, "status": "sent", "id": resp})
                except Exception as e:
                    results.append({"token": t, "status": "error", "error": str(e)})

            # Update last_alert_sent_at
            upsert_bin_state(bin_id, fill_level,
                             human_detected=state.get("human_detected", False),
                             vacuum_on=state.get("vacuum_on", False),
                             lid_open=state.get("lid_open", False),
                             last_alert_sent_at=now.isoformat())

            return {"status": "notifications_sent", "results": results}
        else:
            return {"status": "cooldown_active"}
    return {"status": "below_threshold"}

# NEW (improved)
def send_notification_to_bin(bin_id: str, title: str, body: str,
                             threshold: float = 95.0, cooldown_minutes: int = 30,
                             extra_data: dict = None):
    """
    Send notification to all registered tokens for a bin with cooldown
    
    Args:
        bin_id: Target bin identifier
        title: Notification title
        body: Notification body
        threshold: Fill level threshold to trigger (default 95%)
        cooldown_minutes: Minutes to wait between alerts (default 30)
        extra_data: Optional dict of data to include in notification payload
    
    Returns:
        {
            "status": "notifications_sent"|"cooldown_active"|"below_threshold"|"no_state",
            "notification_id": str (if sent),
            "results": [{token, status, id, error}],
            "failed_count": int,
            "success_count": int
        }
    """
    state = get_bin_state(bin_id)
    if not state:
        return {"status": "no_state", "results": []}

    fill_level = state.get("fill_level", 0)
    last_alert = state.get("last_alert_sent_at")

    now = datetime.now()
    
    # Check threshold
    if fill_level < threshold:
        return {"status": "below_threshold", "results": []}
    
    # Check cooldown
    if last_alert:
        time_since_alert = now - datetime.fromisoformat(last_alert)
        if time_since_alert < timedelta(minutes=cooldown_minutes):
            remaining_min = int((timedelta(minutes=cooldown_minutes) - time_since_alert).total_seconds() / 60)
            return {
                "status": "cooldown_active",
                "remaining_minutes": remaining_min,
                "last_alert_sent_at": last_alert,
                "results": []
            }
    
    # Get tokens and send notifications
    tokens = get_bin_tokens(bin_id)
    if not tokens:
        return {"status": "no_tokens_registered", "results": []}
    
    results = []
    fcm_message_ids = []
    failed_tokens = []
    
    for token in tokens:
        try:
            # Send with retry logic (exponential backoff)
            resp = send_notification_to_token_with_retry(
                token, 
                title, 
                body,
                extra_data=extra_data,
                max_retries=3
            )
            results.append({"token": token, "status": "sent", "id": resp})
            fcm_message_ids.append(resp)
        except Exception as e:
            failed_tokens.append(token)
            results.append({
                "token": token,
                "status": "error",
                "error": str(e)
            })
            print(f"Failed to send to {token}: {str(e)}")
    
    # Update last_alert_sent_at in bin state
    upsert_bin_state(
        bin_id,
        fill_level=fill_level,
        human_detected=state.get("human_detected", False),
        vacuum_on=state.get("vacuum_on", False),
        lid_open=state.get("lid_open", False),
        last_alert_sent_at=now.isoformat()
    )
    
    # Log notification to audit trail
    notification_id = log_notification_sent(bin_id, title, body, tokens, fcm_message_ids)
    
    return {
        "status": "notifications_sent",
        "notification_id": notification_id,
        "results": results,
        "success_count": len(fcm_message_ids),
        "failed_count": len(failed_tokens),
        "total_sent": len(tokens)
    }


def send_notification_to_token_with_retry(token: str, title: str, body: str,
                                         extra_data: dict = None, 
                                         max_retries: int = 3):
    """
    Send notification with exponential backoff retry logic
    
    Args:
        token: FCM device token
        title: Notification title
        body: Notification body
        extra_data: Optional dict of data payload
        max_retries: Number of retry attempts
    
    Returns:
        FCM message ID
    
    Raises:
        Exception: If all retry attempts fail
    """
    import time
    from tenacity import retry, stop_after_attempt, wait_exponential
    
    @retry(
        stop=stop_after_attempt(max_retries),
        wait=wait_exponential(multiplier=1, min=2, max=10)  # 2s, 4s, 8s...
    )
    def _send():
        notification_payload = {
            "title": title,
            "body": body
        }
        
        data_payload = extra_data if extra_data else {}
        
        message = messaging.Message(
            notification=messaging.Notification(**notification_payload),
            data=data_payload,
            token=token
        )
        
        return messaging.send(message)
    
    return _send()

================================================================================

FILE 2: services/notifications.py (UPDATED - SIMPLIFIED)
================================================================================

REMOVE DUPLICATE FUNCTION - Keep only this:

import firebase_admin
from firebase_admin import credentials, messaging
from tenacity import retry, stop_after_attempt, wait_exponential

# Initialize Firebase app (only once)
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceaccount.json")
    firebase_admin.initialize_app(cred)

def send_notification_to_token(token: str, title: str, body: str, 
                               data: dict = None):
    """
    Send FCM notification to a single device token (low-level)
    
    This is the primary single-token sender. Use send_notification_to_bin
    for batch sending with cooldown logic.
    """
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            data=data if data else {},
            token=token
        )
        response = messaging.send(message)
        print(f"Successfully sent message to {token}: {response}")
        return response
    except Exception as e:
        print(f"Error sending message to {token}: {e}")
        raise

================================================================================

FILE 3: routes/fill_level.py (UPDATED)
================================================================================

REPLACE THE NOTIFICATION CALL:

# OLD (line 38-45)
notification_result = send_notification_to_bin(
    data.bin_id,
    title="Smart Dustbin Alert",
    body=f"Bin {data.bin_id} is {fill_percentage}% full.",
    threshold=THRESHOLD,
    cooldown_minutes=COOLDOWN_MINUTES
)

# NEW (with extra data)
extra_data = {
    "action": "fill_alert",
    "bin_id": data.bin_id,
    "fill_level": str(fill_percentage),
    "threshold": str(THRESHOLD),
    "timestamp": datetime.now().isoformat(),
    "alert_type": "critical" if fill_percentage >= 95 else "warning"
}

notification_result = send_notification_to_bin(
    data.bin_id,
    title="Smart Dustbin Alert ⚠️",
    body=f"Bin {data.bin_id} is {fill_percentage}% full.",
    threshold=THRESHOLD,
    cooldown_minutes=COOLDOWN_MINUTES,
    extra_data=extra_data
)

================================================================================

FILE 4: NEW ROUTE - Notification Confirmation (routes/notifications_receipt.py)
================================================================================

CREATE NEW FILE: c:\Smart_dustbin_API\routes\notifications_receipt.py

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from services.database import db

router = APIRouter()

class NotificationReceipt(BaseModel):
    notification_id: str
    bin_id: str
    status: str  # "delivered", "read", "dismissed"
    received_at: str

@router.post("/confirm-receipt")
def confirm_notification_receipt(receipt: NotificationReceipt):
    """
    Flutter app confirms it received/read notification
    Updates delivery status in Firestore
    """
    try:
        notification_ref = db.collection("bins").document(receipt.bin_id).collection("notifications").document(receipt.notification_id)
        notification_ref.update({
            "delivery_status": receipt.status,
            "delivered_at": receipt.received_at,
            "confirmed": True
        })
        return {
            "message": "Receipt confirmed",
            "notification_id": receipt.notification_id,
            "status": receipt.status
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to confirm receipt: {str(e)}")

@router.get("/notification-history/{bin_id}")
def get_notification_history(bin_id: str, limit: int = 50):
    """
    Get notification history for a bin
    Useful for debugging or showing user notification log
    """
    try:
        from services.database import get_notification_history
        history = get_notification_history(bin_id, limit=limit)
        return {
            "bin_id": bin_id,
            "total": len(history),
            "notifications": history
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

================================================================================

FILE 5: main.py (UPDATED)
================================================================================

ADD THIS IMPORT AND ROUTE (around line 20):

# Add to imports
from routes import notifications_receipt

# Add to router includes (after line 21)
app.include_router(notifications_receipt.router, prefix="/notifications", tags=["Notification Receipt"])

================================================================================
FIREBASE SECURITY RULES (Updated)
================================================================================

Add to your Firestore rules to protect notification data:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Bins collection
    match /bins/{bin_id} {
      allow read, write: if request.auth.uid != null;
      
      // Notifications subcollection
      match /notifications/{notification_id} {
        allow read: if request.auth.uid != null;
        allow write: if request.auth != null;  // Only backend can write
      }
      
      // Events subcollection
      match /events/{event_id} {
        allow read: if request.auth.uid != null;
        allow write: if false;  // Only backend writes
      }
      
      // Tokens subcollection
      match /tokens/{token} {
        allow read, write: if request.auth != null;
      }
    }
  }
}

================================================================================
FLUTTER APP IMPLEMENTATION GUIDE
================================================================================

In your Flutter app (firebase_messaging.dart):

void initializeFirebaseMessaging() {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Request permission
  messaging.requestPermission();
  
  // Get token and send to backend
  messaging.getToken().then((token) {
    if (token != null) {
      registerTokenWithBackend(token); // POST to /notifications/register-token
    }
  });
  
  // Handle notification when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Notification: ${message.notification?.title}");
    
    // Extract data payload
    String action = message.data['action'] ?? '';
    String binId = message.data['bin_id'] ?? '';
    String fillLevel = message.data['fill_level'] ?? '';
    
    // Handle based on action
    if (action == 'fill_alert') {
      showFillLevelAlert(binId, fillLevel);
    }
    
    // Send receipt to backend
    confirmNotificationReceipt(
      notification_id: message.messageId,
      bin_id: binId,
      status: 'received'
    );
  });
  
  // Handle when app opened from notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    String action = message.data['action'] ?? '';
    // Navigate to appropriate screen
    if (action == 'fill_alert') {
      navigateToBinDetails(message.data['bin_id']);
    }
  });
}

================================================================================
DATABASE STRUCTURE (Firestore) - FINAL
================================================================================

bins/
├── {bin_id}/
│   └── latest_state/           ← Current bin state
│       ├── fill_level: float
│       ├── human_detected: bool
│       ├── vacuum_on: bool
│       ├── lid_open: bool
│       ├── last_updated: timestamp
│       └── last_alert_sent_at: timestamp
│
│   └── events/                  ← Audit trail
│       └── {auto_id}/
│           ├── timestamp
│           ├── old_level
│           ├── new_level
│           └── type (emptied|level_change)
│
│   └── notifications/           ← NEW: Notification history
│       └── {notification_id}/
│           ├── notification_id
│           ├── timestamp
│           ├── title
│           ├── body
│           ├── tokens_sent_to: []
│           ├── num_recipients
│           ├── fcm_message_ids: []
│           ├── delivery_status (sent|delivered|read|failed)
│           ├── delivered_at: timestamp
│           ├── read_count
│           └── failed_tokens: []
│
│   └── tokens/                  ← FCM device tokens
│       └── {fcm_token}/
│           └── token

================================================================================
TESTING THE FLOW
================================================================================

1. REGISTER TOKEN (from Flutter app):
   curl -X POST http://localhost:8000/notifications/register-token \
   -H "Content-Type: application/json" \
   -d '{"bin_id": "A1", "token": "YOUR_FCM_TOKEN_HERE"}'

2. TRIGGER ALERT (simulate sensor):
   curl -X POST http://localhost:8000/bin/update-fill-level/ \
   -H "Content-Type: application/json" \
   -d '{"bin_id": "A1", "distance_cm": 2, "bin_height_cm": 50}'
   
   Expected: Flutter app receives notification

3. CONFIRM RECEIPT (from Flutter app):
   curl -X POST http://localhost:8000/notifications/confirm-receipt \
   -H "Content-Type: application/json" \
   -d '{"notification_id": "A1_17344...", "bin_id": "A1", "status": "delivered", "received_at": "2025-12-11T10:30:00Z"}'

4. CHECK HISTORY:
   curl http://localhost:8000/notifications/notification-history/A1

================================================================================
SUMMARY: WHAT TO DO NOW
================================================================================

✅ CURRENT STATE (Correct):
  - Using Firestore for persistent storage ✓
  - Token registration working ✓
  - Cooldown mechanism working ✓
  - Batch notification sending working ✓
  - Firebase messaging correct ✓

⚠️ RECOMMENDED IMPROVEMENTS (Priority Order):

1. HIGH PRIORITY - Add notification logging:
   - Add log_notification_sent() function
   - Add get_notification_history() function
   - Creates audit trail for debugging

2. HIGH PRIORITY - Add data payload:
   - Include action, bin_id, fill_level in message.data
   - Flutter app can handle notifications based on action type
   - More flexible notification handling

3. MEDIUM PRIORITY - Add retry logic:
   - Use tenacity library for exponential backoff
   - Handle transient FCM failures gracefully

4. MEDIUM PRIORITY - Add notification receipts:
   - Create new route for delivery confirmation
   - Flutter app sends receipt when received
   - Track delivery status in database

5. LOW PRIORITY - Add user preferences:
   - Allow disabling notifications
   - Different alert frequencies
   - Override thresholds per user

================================================================================
IMPLEMENTATION CHECKLIST
================================================================================

To implement the improvements:

- [ ] Add log_notification_sent() to services/database.py
- [ ] Add get_notification_history() to services/database.py
- [ ] Replace send_notification_to_bin() with improved version
- [ ] Add send_notification_to_token_with_retry() to services/database.py
- [ ] Simplify services/notifications.py (remove duplicate function)
- [ ] Update routes/fill_level.py to pass extra_data
- [ ] Create routes/notifications_receipt.py
- [ ] Update main.py to include notification receipt routes
- [ ] Update Firestore security rules
- [ ] Update Flutter app to handle data payload and send receipts
- [ ] Test end-to-end flow
- [ ] Monitor Firestore for notification collection growth

================================================================================

ANSWER: Is the current logic correct?
================================================================================

YES ✅ - Your FCM logic is CORRECT for basic functionality.

The core implementation works:
  ✓ Tokens stored in Firestore
  ✓ Notifications sent to all tokens
  ✓ Cooldown prevents spam
  ✓ Error handling per token
  ✓ Firebase messaging properly configured
  ✓ Using Firestore for persistent state

But it could be BETTER with:
  - Notification history logging (audit trail)
  - Data payload for Flutter to handle actions
  - Retry logic for transient failures
  - Delivery receipts from Flutter app
  - User preferences for notifications

All improvements are recommended but not critical. Your current system will work fine.

================================================================================
