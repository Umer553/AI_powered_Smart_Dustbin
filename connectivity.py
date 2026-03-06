import firebase_admin
from firebase_admin import credentials, firestore

# Load your service account JSON
cred = credentials.Certificate("serviceaccount.json")

# Initialize Firebase app
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

# Test write/read
doc_ref = db.collection("connection_test").document("ping")
doc_ref.set({"status": "ok"})
result = doc_ref.get().to_dict()

if result and result.get("status") == "ok":
    print("✅ Firestore connection successful!")
else:
    print("⚠️ Firestore connection failed.")
