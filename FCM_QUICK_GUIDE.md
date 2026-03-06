# 🚀 FCM NOTIFICATION FLOW - Quick Implementation Guide

## Current Flow (What You Have - Working ✅)

```
Sensor Data
    ↓
POST /bin/update-fill-level/
    ↓
Calculate fill_percentage
    ↓
upsert_bin_state() → Firestore (bins/{bin_id}/latest_state)
    ↓
Check threshold (95%)
    ↓
send_notification_to_bin()
    ├─ Check cooldown (30 min)
    ├─ Get all tokens from Firestore (bins/{bin_id}/tokens/{token})
    ├─ Loop through tokens
    └─ Send FCM message to each token
        ↓
    Firebase Cloud Messaging
        ↓
    Flutter App (receives in foreground/background)
```

---

## What Firestore Stores (Database Usage ✅)

### Collections/Documents:

```
bins/
├── bin_A1/
│   ├── latest_state/  ← Current state
│   │   ├── fill_level: 95.5
│   │   ├── human_detected: false
│   │   ├── vacuum_on: false
│   │   ├── lid_open: true
│   │   ├── last_updated: "2025-12-11T10:30:00Z"
│   │   └── last_alert_sent_at: "2025-12-11T10:25:00Z"
│   │
│   ├── events/  ← Audit log
│   │   ├── event_id_1/
│   │   │   ├── timestamp: "2025-12-11T10:00:00Z"
│   │   │   ├── old_level: 40.0
│   │   │   ├── new_level: 50.0
│   │   │   └── type: "level_change"
│   │   └── event_id_2/
│   │       ├── timestamp: "2025-12-11T10:30:00Z"
│   │       ├── old_level: 90.0
│   │       ├── new_level: 0.0
│   │       └── type: "emptied"
│   │
│   └── tokens/  ← Device tokens
│       ├── "fcm_token_device_1"/
│       │   └── token: "fcm_token_device_1"
│       └── "fcm_token_device_2"/
│           └── token: "fcm_token_device_2"
```

---

## What Database To Use?

**Answer: Firestore (which you're using) ✅**

### Why Firestore?

| Aspect | Firestore | SQL DB | Why Firestore |
|--------|-----------|--------|---------------|
| **Real-time** | ✅ Yes | ❌ No | Instant updates |
| **Scalability** | ✅ Excellent | ⚠️ Scaling effort | Auto-scales |
| **Cost** | ✅ Pay-per-use | ⚠️ Fixed | Cheaper for IoT |
| **Security** | ✅ Built-in | ⚠️ Extra work | Auth built-in |
| **Integration** | ✅ FCM native | ❌ No | Works with FCM |
| **Mobile app** | ✅ Direct SDK | ⚠️ API needed | Flutter can use SDK |

**Your setup is OPTIMAL** for this use case.

---

## How Notifications Get To Flutter App

```
Backend (Python/FastAPI)
    ↓
Call firebase_admin.messaging.send()
    ↓
Firebase Cloud Messaging (Google Cloud)
    ↓
Check device token valid?
    ├─ YES → Send to device
    └─ NO → Delivery fails, log error
    ↓
Device receives (if online)
    ↓
Flutter app handles via Firebase Messaging plugin:
    ├─ Foreground: onMessage listener
    ├─ Background: onBackgroundMessage handler
    └─ Tapped: onMessageOpenedApp listener
```

---

## Your Current FCM Implementation ✅ vs Improved 🔧

### What's Working Now:

```python
# Fill level crosses 95% → send notification
send_notification_to_bin(
    bin_id="A1",
    title="Smart Dustbin Alert",
    body="Bin A1 is 95% full.",
    threshold=95.0,
    cooldown_minutes=30
)

# Backend:
# 1. Gets all tokens: ["token1", "token2", "token3"]
# 2. Loops through and sends: messaging.send(message)
# 3. Updates: last_alert_sent_at
# 4. Returns: results with status for each token

# Flutter app receives:
# Notification {
#   title: "Smart Dustbin Alert",
#   body: "Bin A1 is 95% full."
# }
```

**Problem:** Flutter app doesn't know WHICH bin or what ACTION to take.

### What Should Change:

```python
# Same but with data payload:
send_notification_to_bin(
    bin_id="A1",
    title="Smart Dustbin Alert ⚠️",
    body="Bin A1 is 95% full.",
    threshold=95.0,
    cooldown_minutes=30,
    extra_data={  # ← NEW: Data payload
        "action": "fill_alert",
        "bin_id": "A1",
        "fill_level": "95.5",
        "timestamp": "2025-12-11T10:30:00Z"
    }
)

# Flutter app receives:
# RemoteMessage {
#   notification: {
#     title: "Smart Dustbin Alert ⚠️",
#     body: "Bin A1 is 95% full."
#   },
#   data: {
#     "action": "fill_alert",
#     "bin_id": "A1",
#     "fill_level": "95.5",
#     "timestamp": "2025-12-11T10:30:00Z"
#   }
# }

# Now Flutter can do:
if (message.data['action'] == 'fill_alert') {
    navigateToBinDetails(message.data['bin_id']);
    showAlert("Bin ${binId} is ${fillLevel}% full!");
}
```

---

## Key Differences: Database vs Notification

| Aspect | Database (Firestore) | Notification (FCM) |
|--------|---------------------|-------------------|
| **Purpose** | Store persistent state | Send real-time alert |
| **Reliability** | 100% saved | Best effort delivery |
| **When arrives** | Immediate | 10-30 seconds (typical) |
| **Can retry** | Yes, pull from DB | No, fire-and-forget |
| **Can trace** | Yes, full history | Maybe, message IDs only |
| **Cost** | Per read/write | Per notification sent |

**You need BOTH:**
- Database for: State tracking, history, recovery
- Notifications for: Real-time alerts to user

---

## Testing Your Current Setup

### 1. Register a Token (from Flutter app):
```bash
curl -X POST http://localhost:8000/notifications/register-token \
  -H "Content-Type: application/json" \
  -d '{
    "bin_id": "A1",
    "token": "YOUR_REAL_FCM_TOKEN"
  }'
```

**Response:**
```json
{
  "message": "Token registered successfully",
  "bin_id": "A1"
}
```

### 2. Check Firestore (should have new token):
```
bins/A1/tokens/YOUR_REAL_FCM_TOKEN
  └── token: "YOUR_REAL_FCM_TOKEN"
```

### 3. Trigger Notification (simulate sensor):
```bash
curl -X POST http://localhost:8000/bin/update-fill-level/ \
  -H "Content-Type: application/json" \
  -d '{
    "bin_id": "A1",
    "distance_cm": 2,
    "bin_height_cm": 50
  }'
```

**Response:**
```json
{
  "message": "Fill level updated successfully",
  "bin_id": "A1",
  "fill_level_percentage": 96.0,
  "notification_status": "notifications_sent"
}
```

### 4. Check Flutter App:
- Should see notification popup if app in foreground
- Should see notification in system tray if app in background

---

## Recommended Changes (Priority)

### ✅ HIGH PRIORITY (Do this now)

**1. Add data payload to notifications:**
```python
# Before sending, add data
extra_data = {
    "action": "fill_alert",
    "bin_id": bin_id,
    "fill_level": str(fill_percentage)
}
message = messaging.Message(
    notification=messaging.Notification(title, body),
    data=extra_data,  # ← Add this
    token=token
)
```

**Impact:** Flutter app can handle different notification types

### ⚠️ MEDIUM PRIORITY (Do this next)

**2. Log notification history:**
```python
# After sending, save to Firestore
bins/{bin_id}/notifications/{notification_id}
  ├── timestamp
  ├── title
  ├── body
  ├── fcm_message_ids: [...]
  └── delivery_status: "sent"
```

**Impact:** Can debug, retry, or show history to users

**3. Add retry logic:**
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential())
def send_notification_to_token(...):
    ...
```

**Impact:** Handles transient FCM failures automatically

### 📋 LOW PRIORITY (Nice to have)

**4. Delivery receipts:**
```python
# Flutter app sends: 
POST /notifications/confirm-receipt
  ├── notification_id
  ├── bin_id
  ├── status: "delivered"
  └── timestamp

# Backend updates Firestore:
bins/{bin_id}/notifications/{id}/delivery_status = "delivered"
```

**Impact:** Know if user actually received message

---

## Quick Summary

### Is FCM logic correct? **YES ✅**
- Token registration: ✅
- Batch sending: ✅
- Cooldown: ✅
- Error handling: ✅

### Are you using database? **YES ✅**
- Using Firestore: ✅
- Storing state: ✅
- Storing events: ✅
- Storing tokens: ✅

### What to improve?
1. Add data payload (HIGH)
2. Log notification history (MEDIUM)
3. Add retry logic (MEDIUM)
4. Add delivery receipts (LOW)

### How to send notification to Flutter?
```
Sensor → Backend → Firestore (state) → FCM (alert) → Flutter
```

---

## Files to Look At

| File | What | Line |
|------|------|------|
| services/database.py | send_notification_to_bin() | 92-129 |
| services/notifications.py | send_notification_to_token() | 10-20 |
| routes/fill_level.py | Call send_notification_to_bin | 38-45 |
| routes/Fcm_token.py | Register token endpoint | 11-18 |

---

## Next Steps

1. **Test current setup** - Register token, trigger alert, check Flutter
2. **Add data payload** - Pass extra_data to messaging.Message
3. **Add logging** - Create notifications collection in Firestore
4. **Add retry** - Install tenacity, use @retry decorator
5. **Add receipts** - Create /notifications/confirm-receipt endpoint

All detailed code examples in: `FCM_LOGIC_ANALYSIS.md`

