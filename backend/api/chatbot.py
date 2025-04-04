from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
import speech_recognition as sr
from io import BytesIO
from PIL import Image
import tempfile
import os

from utils.database import get_db
from utils.auth import get_current_active_user
from utils.config import settings
from models.user import User
from services.openai_service import process_chat_message, process_image, transcribe_audio
from services.todo_service import create_todo_from_text
from services.calendar_service import create_event_from_text
from services.summary_service import generate_daily_summary

router = APIRouter()

# Pydantic models for request/response
class ChatMessage(BaseModel):
    role: str
    content: str
    timestamp: Optional[datetime] = None
    
    class Config:
        orm_mode = True

class ChatRequest(BaseModel):
    message: str
    
    class Config:
        orm_mode = True

class ChatResponse(BaseModel):
    response: str
    generated_items: Optional[List[dict]] = None
    
    class Config:
        orm_mode = True

class ConfirmationRequest(BaseModel):
    item_type: str  # "todo" or "event"
    item_data: dict
    confirmed: bool
    
    class Config:
        orm_mode = True

@router.post("/chat/text", response_model=ChatResponse)
async def chat_text(
    chat_request: ChatRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    if not settings.OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="OpenAI API key is not configured")
    
    # Process message
    response, generated_items = await process_chat_message(
        chat_request.message, 
        current_user.id,
        db
    )
    
    return {
        "response": response,
        "generated_items": generated_items
    }

@router.post("/chat/audio", response_model=ChatResponse)
async def chat_audio(
    audio_file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    if not settings.OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="OpenAI API key is not configured")
    
    # Save uploaded audio file to a temporary location
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
        temp_audio.write(await audio_file.read())
        temp_audio_path = temp_audio.name
    
    try:
        # Transcribe audio to text
        transcribed_text = await transcribe_audio(temp_audio_path)
        
        if not transcribed_text:
            raise HTTPException(status_code=400, detail="Could not transcribe audio")
        
        # Process the transcribed text
        response, generated_items = await process_chat_message(
            transcribed_text, 
            current_user.id,
            db
        )
        
        return {
            "response": response,
            "generated_items": generated_items
        }
    finally:
        # Clean up temporary file
        if os.path.exists(temp_audio_path):
            os.remove(temp_audio_path)

@router.post("/chat/image", response_model=ChatResponse)
async def chat_image(
    image_file: UploadFile = File(...),
    prompt: str = Form("What's in this image?"),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    if not settings.OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="OpenAI API key is not configured")
    
    # Read and validate image
    image_data = await image_file.read()
    
    try:
        # Process image
        response, generated_items = await process_image(
            image_data,
            prompt,
            current_user.id,
            db
        )
        
        return {
            "response": response,
            "generated_items": generated_items
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error processing image: {str(e)}")

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
    if not settings.OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="OpenAI API key is not configured")
    
    summary = await generate_daily_summary(current_user.id, db)
    
    return {"summary": summary} 