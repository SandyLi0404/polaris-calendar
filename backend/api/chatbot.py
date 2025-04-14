from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime, timedelta
import tempfile
import os

from utils.database import get_db
from utils.config import settings
from models.calendar import Event
from models.todo import TodoItem
from services.todo_service import create_todo_from_text
from services.calendar_service import create_event_from_text
from services.together_ai_service import process_chat_message

router = APIRouter()

# In-memory conversation history store (simple implementation)
# For production, this should be stored in database
# Key is user_id, value is list of conversation messages
conversation_history = {}

# Pydantic models for request/response
class ChatMessage(BaseModel):
    role: str
    content: str
    timestamp: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class ChatRequest(BaseModel):
    message: str
    
    class Config:
        from_attributes = True

class ChatResponse(BaseModel):
    response: str
    created_items: Optional[List[dict]] = None
    
    class Config:
        from_attributes = True

@router.post("/chat/text", response_model=ChatResponse)
async def chat_text(
    chat_request: ChatRequest,
    db: Session = Depends(get_db)
):
    if not settings.TOGETHER_API_KEY:
        raise HTTPException(status_code=500, detail="Together API key is not configured")
    
    # Fixed user ID (single user system)
    user_id = 1
    
    # Get or initialize conversation history for this user
    if user_id not in conversation_history:
        conversation_history[user_id] = []
    
    # Add user message to history
    conversation_history[user_id].append({"role": "user", "content": chat_request.message})
    
    # Process message using Together AI with conversation history
    response, generated_items = await process_chat_message(
        chat_request.message, 
        user_id,
        db,
        conversation_history[user_id]
    )
    
    # Add AI response to history
    conversation_history[user_id].append({"role": "assistant", "content": response})
    
    # Keep history to a reasonable size (last 10 messages)
    if len(conversation_history[user_id]) > 20:
        conversation_history[user_id] = conversation_history[user_id][-20:]
    
    # Directly create items based on LLM output without additional confirmation
    created_items = []
    if generated_items:
        for item in generated_items:
            try:
                if item["type"] == "todo":
                    todo_item = create_todo_from_text(item["data"], user_id, db)
                    created_items.append({
                        "type": "todo",
                        "id": todo_item.id,
                        "title": todo_item.title
                    })
                    print(f"Successfully created todo item: {todo_item.title} with ID: {todo_item.id}")
                elif item["type"] == "event":
                    event = create_event_from_text(item["data"], user_id, db)
                    created_items.append({
                        "type": "event",
                        "id": event.id,
                        "title": event.title
                    })
                    print(f"Successfully created event: {event.title} with ID: {event.id}")
            except Exception as e:
                print(f"Error creating item: {str(e)}")
                # Continue even if one item fails
    
    # Only return created_items if we actually created something
    has_created_items = len(created_items) > 0
    
    return {
        "response": response,
        "created_items": created_items if has_created_items else None
    }

@router.get("/daily-summary", response_model=dict)
async def get_daily_summary(
    db: Session = Depends(get_db)
):
    # Fixed user ID (single user system)
    user_id = 1
    
    # Create a simple text-based summary
    # Get today's date
    today = datetime.now().date()
    tomorrow = today + timedelta(days=1)
    
    # Get today's events
    events = db.query(Event).filter(
        Event.user_id == user_id,
        Event.start_time >= today,
        Event.start_time < tomorrow
    ).order_by(Event.start_time).all()
    
    # Get incomplete todo items
    todo_items = db.query(TodoItem).filter(
        TodoItem.user_id == user_id,
        TodoItem.is_completed == False
    ).order_by(TodoItem.deadline).all()
    
    # Create simple summary
    summary = f"Daily Summary for {today.strftime('%A, %B %d, %Y')}:\n\n"
    
    if events:
        summary += "Today's Events:\n"
        for event in events:
            time_str = event.start_time.strftime('%I:%M %p') if not event.is_all_day else "All day"
            summary += f"- {time_str}: {event.title}\n"
    else:
        summary += "No events scheduled for today.\n"
    
    summary += "\nTasks:\n"
    if todo_items:
        for item in todo_items:
            deadline = item.deadline.strftime('%m/%d/%Y') if item.deadline else "No deadline"
            summary += f"- {item.title} (Due: {deadline})\n"
    else:
        summary += "No pending tasks.\n"
    
    return {"summary": summary}

@router.post("/chat/clear-history", response_model=dict)
async def clear_chat_history():
    """
    Clear the conversation history for the user
    """
    # Fixed user ID (single user system)
    user_id = 1
    
    if user_id in conversation_history:
        conversation_history[user_id] = []
    
    return {"message": "Conversation history cleared successfully"} 