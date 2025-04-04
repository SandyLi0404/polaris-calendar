from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
from pydantic import BaseModel
import uuid

from utils.database import get_db
from utils.auth import get_current_active_user
from models.user import User
from models.calendar import Event, Tag, Reminder
from services.ics_service import create_ics_file, import_ics_file, export_event_to_ics

router = APIRouter()

# Pydantic models for request/response
class ReminderCreate(BaseModel):
    minutes_before: int = 15
    
    class Config:
        orm_mode = True

class ReminderResponse(BaseModel):
    id: int
    minutes_before: int
    is_sent: bool
    
    class Config:
        orm_mode = True

class TagCreate(BaseModel):
    name: str
    color: str = "#3498db"
    
    class Config:
        orm_mode = True

class TagResponse(BaseModel):
    id: int
    name: str
    color: str
    
    class Config:
        orm_mode = True

class EventCreate(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: datetime
    end_time: datetime
    location: Optional[str] = None
    is_all_day: bool = False
    tag_ids: List[int] = []
    reminders: List[ReminderCreate] = [ReminderCreate()]
    
    class Config:
        orm_mode = True

class EventResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    start_time: datetime
    end_time: datetime
    location: Optional[str] = None
    is_all_day: bool
    ics_uid: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    tags: List[TagResponse] = []
    reminders: List[ReminderResponse] = []
    
    class Config:
        orm_mode = True

# Tag endpoints
@router.get("/tags", response_model=List[TagResponse])
async def get_tags(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    return db.query(Tag).filter(Tag.user_id == current_user.id).all()

@router.post("/tags", response_model=TagResponse)
async def create_tag(
    tag: TagCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Check if tag already exists
    existing_tag = db.query(Tag).filter(
        Tag.name == tag.name,
        Tag.user_id == current_user.id
    ).first()
    
    if existing_tag:
        raise HTTPException(status_code=400, detail="Tag already exists")
    
    # Create new tag
    db_tag = Tag(
        name=tag.name,
        color=tag.color,
        user_id=current_user.id
    )
    
    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)
    
    return db_tag

@router.delete("/tags/{tag_id}", response_model=dict)
async def delete_tag(
    tag_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Get tag
    tag = db.query(Tag).filter(
        Tag.id == tag_id,
        Tag.user_id == current_user.id
    ).first()
    
    if not tag:
        raise HTTPException(status_code=404, detail="Tag not found")
    
    # Delete tag
    db.delete(tag)
    db.commit()
    
    return {"message": "Tag deleted successfully"}

# Event endpoints
@router.get("/events", response_model=List[EventResponse])
async def get_events(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    tag_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    query = db.query(Event).filter(Event.user_id == current_user.id)
    
    # Filter by date range
    if start_date:
        query = query.filter(Event.end_time >= start_date)
    if end_date:
        query = query.filter(Event.start_time <= end_date)
    
    # Filter by tag
    if tag_id:
        tag = db.query(Tag).filter(Tag.id == tag_id, Tag.user_id == current_user.id).first()
        if not tag:
            raise HTTPException(status_code=404, detail="Tag not found")
        query = query.filter(Event.tags.contains(tag))
    
    return query.all()

@router.get("/events/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id
    ).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    return event

@router.post("/events", response_model=EventResponse)
async def create_event(
    event: EventCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Check for date validity
    if event.end_time < event.start_time:
        raise HTTPException(status_code=400, detail="End time must be after start time")
    
    # Check for conflicts
    conflicts = db.query(Event).filter(
        Event.user_id == current_user.id,
        Event.start_time < event.end_time,
        Event.end_time > event.start_time
    ).all()
    
    if conflicts:
        # We could handle this better, but for now just warning
        pass  # In a real app, we might want to return conflict information
    
    # Get tags
    tags = []
    for tag_id in event.tag_ids:
        tag = db.query(Tag).filter(Tag.id == tag_id, Tag.user_id == current_user.id).first()
        if tag:
            tags.append(tag)
    
    # Create ICS UID
    ics_uid = str(uuid.uuid4())
    
    # Create new event
    db_event = Event(
        title=event.title,
        description=event.description,
        start_time=event.start_time,
        end_time=event.end_time,
        location=event.location,
        is_all_day=event.is_all_day,
        ics_uid=ics_uid,
        user_id=current_user.id,
        tags=tags
    )
    
    db.add(db_event)
    db.commit()
    db.refresh(db_event)
    
    # Add reminders
    for reminder_data in event.reminders:
        reminder = Reminder(
            minutes_before=reminder_data.minutes_before,
            event_id=db_event.id
        )
        db.add(reminder)
    
    db.commit()
    db.refresh(db_event)
    
    # Generate ICS file (in a real app, this would be stored somewhere)
    create_ics_file(db_event)
    
    return db_event

@router.put("/events/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: int,
    event_data: EventCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Check date validity
    if event_data.end_time < event_data.start_time:
        raise HTTPException(status_code=400, detail="End time must be after start time")
    
    # Get event
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id
    ).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    # Update event fields
    event.title = event_data.title
    event.description = event_data.description
    event.start_time = event_data.start_time
    event.end_time = event_data.end_time
    event.location = event_data.location
    event.is_all_day = event_data.is_all_day
    
    # Update tags
    new_tags = []
    for tag_id in event_data.tag_ids:
        tag = db.query(Tag).filter(Tag.id == tag_id, Tag.user_id == current_user.id).first()
        if tag:
            new_tags.append(tag)
    event.tags = new_tags
    
    # Update reminders
    # Delete existing reminders
    db.query(Reminder).filter(Reminder.event_id == event.id).delete()
    
    # Add new reminders
    for reminder_data in event_data.reminders:
        reminder = Reminder(
            minutes_before=reminder_data.minutes_before,
            event_id=event.id
        )
        db.add(reminder)
    
    db.commit()
    db.refresh(event)
    
    # Update ICS file
    create_ics_file(event)
    
    return event

@router.delete("/events/{event_id}", response_model=dict)
async def delete_event(
    event_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Get event
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id
    ).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    # Delete event
    db.delete(event)
    db.commit()
    
    return {"message": "Event deleted successfully"}

@router.get("/events/{event_id}/export-ics", response_model=dict)
async def export_event_ics(
    event_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Get event
    event = db.query(Event).filter(
        Event.id == event_id,
        Event.user_id == current_user.id
    ).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    # Export to ICS
    ics_content = export_event_to_ics(event)
    
    return {
        "ics_content": ics_content,
        "filename": f"{event.title.replace(' ', '_')}.ics"
    }

@router.post("/import-ics", response_model=List[EventResponse])
async def import_ics(
    ics_file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Read ICS file content
    ics_content = await ics_file.read()
    
    # Import events from ICS
    imported_events = import_ics_file(ics_content, current_user.id, db)
    
    return imported_events 