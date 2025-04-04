import uvicorn
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware

from api.calendar import router as calendar_router
from api.todo import router as todo_router
from api.chatbot import router as chatbot_router
from api.auth import router as auth_router
from services.scheduler import start_scheduler

app = FastAPI(
    title="Polaris Calendar API",
    description="API for Polaris Calendar application",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"])
app.include_router(calendar_router, prefix="/api/calendar", tags=["Calendar"])
app.include_router(todo_router, prefix="/api/todo", tags=["Todo"])
app.include_router(chatbot_router, prefix="/api/chatbot", tags=["Chatbot"])

@app.on_event("startup")
async def startup_event():
    # Start the scheduler for reminders and daily summaries
    start_scheduler()

@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Welcome to Polaris Calendar API",
        "docs": "/docs",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True) 