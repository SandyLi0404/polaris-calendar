from datetime import datetime, timedelta
from typing import Dict, Any
import dateutil.parser
import uuid

from models.calendar import Event, Reminder
from services.ics_service import create_ics_file

def create_event_from_text(event_data: Dict[str, Any], user_id: int, db) -> Event:
    """
    Create a calendar event from structured data extracted from text
    
    Args:
        event_data: Dictionary containing event data
        user_id: The ID of the user
        db: Database session
        
    Returns:
        The created Event
    """
    # Extract fields from data
    title = event_data.get("title", "Untitled Event")
    description = event_data.get("description", "")
    location = event_data.get("location", "")
    is_all_day = event_data.get("is_all_day", False)
    
    # Parse start and end times
    start_time = None
    if event_data.get("start_time"):
        try:
            start_time = dateutil.parser.parse(event_data["start_time"])
        except:
            # If parsing fails, use current time
            start_time = datetime.now()
    else:
        # Default to current time
        start_time = datetime.now()
    
    end_time = None
    if event_data.get("end_time"):
        try:
            end_time = dateutil.parser.parse(event_data["end_time"])
        except:
            # If parsing fails, use start time + 1 hour
            end_time = start_time + timedelta(hours=1)
    else:
        # Default to start time + 1 hour
        end_time = start_time + timedelta(hours=1)
    
    # Create ICS UID
    ics_uid = str(uuid.uuid4())
    
    # Create new event
    event = Event(
        title=title,
        description=description,
        start_time=start_time,
        end_time=end_time,
        location=location,
        is_all_day=is_all_day,
        ics_uid=ics_uid,
        user_id=user_id
    )
    
    db.add(event)
    db.commit()
    db.refresh(event)
    
    # Add a default reminder
    reminder = Reminder(
        minutes_before=15,  # Default to 15 minutes before
        event_id=event.id
    )
    db.add(reminder)
    db.commit()
    db.refresh(event)
    
    # Generate ICS file
    create_ics_file(event)
    
    return event 