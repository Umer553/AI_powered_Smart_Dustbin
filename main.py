from fastapi import FastAPI, HTTPException
# from fastapi.middleware.cors import CORSMiddleware

# Import routers
from routes import fill_level, controls, Fcm_token
from routes.human_detection import router as human_detection_router

# Firestore client
from services.database import db

# ===========================
# Initialize FastAPI app
# ===========================
app = FastAPI(
    title="Smart Dustbin API",
    description="Backend service for Smart Dustbin project. "
                "Handles sensor updates, control commands, and push notifications.",
    version="1.0.0",
    contact={
        "name": "Smart Dustbin Team",
        "email": "smartdustbin@support.com"
    }
)

# ===========================
# Configure CORS
# # ===========================
# origins = [ "*" ]  # Allow all origins for development; restrict in production
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Change to specific domains in production
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Routers
# app.include_router(fill_level.router, prefix="/bin", tags=["Bin Fill Level"])
# app.include_router(controls.router, prefix="/commands_control", tags=["Bin Controls"])
# app.include_router(Fcm_token.router, prefix="/notifications", tags=["FCM Tokens"])
app.include_router(human_detection_router, prefix="/Human Detection", tags=["Detection"])

@app.get("/health", tags=["System"])
def health_check():
    try:
        test_ref = db.collection("health").document("ping")
        test_ref.set({"status": "ok"})
        doc = test_ref.get()
        if doc.exists:
            return {"status": "healthy", "firestore": "connected"}
        else:
            raise HTTPException(status_code=500, detail="Firestore not responding")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")
