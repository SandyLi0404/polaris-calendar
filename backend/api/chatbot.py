from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime, timedelta
import tempfile
import os

from utils.database import get_db
from utils.auth import get_current_active_user
from utils.config import settings
from models.user import User
from models.calendar import Event
from models.todo import TodoItem
from services.todo_service import create_todo_from_text
from services.calendar_service import create_event_from_text
from services.together_ai_service import process_chat_message

router = APIRouter()

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
    generated_items: Optional[List[dict]] = None
    
    class Config:
        from_attributes = True

class ConfirmationRequest(BaseModel):
    item_type: str  # "todo" or "event"
    item_data: dict
    confirmed: bool
    
    class Config:
        from_attributes = True

@router.post("/chat/text", response_model=ChatResponse)
async def chat_text(
    chat_request: ChatRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    
    if not settings.TOGETHER_API_KEY:
        raise HTTPException(status_code=500, detail="Together API key is not configured")
    
    # Process message using Together AI
    response, generated_items = await process_chat_message(
        chat_request.message, 
        current_user.id,
        db
    )
    
    return {
        "response": response,
        "generated_items": generated_items
    }

@router.post("/confirm-item", response_model=dict)
async def confirm_item(
    confirmation: ConfirmationRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    if not confirmation.confirmed:
        return {"message": "Item creation cancelled"}
    
    try:
        if confirmation.item_type == "todo":
            todo_item = create_todo_from_text(confirmation.item_data, current_user.id, db)
            return {"message": "Todo item created successfully", "item_id": todo_item.id}
        elif confirmation.item_type == "event":
            event = create_event_from_text(confirmation.item_data, current_user.id, db)
            return {"message": "Event created successfully", "item_id": event.id}
        else:
            raise HTTPException(status_code=400, detail="Invalid item type")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error creating item: {str(e)}")

@router.get("/daily-summary", response_model=dict)
async def get_daily_summary(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Create a simple text-based summary
    # Get today's date
    today = datetime.now().date()
    tomorrow = today + timedelta(days=1)
    
    # Get user
    user = db.query(User).filter(User.id == current_user.id).first()
    if not user:
        return {"summary": "User not found"}
    
    # Get today's events
    events = db.query(Event).filter(
        Event.user_id == current_user.id,
        Event.start_time >= today,
        Event.start_time < tomorrow
    ).order_by(Event.start_time).all()
    
    # Get incomplete todo items
    todo_items = db.query(TodoItem).filter(
        TodoItem.user_id == current_user.id,
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