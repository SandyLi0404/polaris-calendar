from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api import auth, calendar, todo, chatbot

app = FastAPI(title="Polaris Calendar API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(calendar.router, prefix="/api/calendar", tags=["Calendar"])
app.include_router(todo.router, prefix="/api/todo", tags=["Todo"])
app.include_router(chatbot.router, prefix="/api/chatbot", tags=["Chatbot"])

@app.get("/")
async def root():
    return {"message": "Welcome to Polaris Calendar API"} 