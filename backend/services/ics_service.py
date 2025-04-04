from icalendar import Calendar, Event as ICalEvent, vCalAddress, vText
from datetime import datetime, timedelta
from typing import List
import uuid
import pytz

from models.calendar import Event, Reminder, Tag

def create_ics_file(event: Event) -> str:
    """
    Create an ICS file from an event
    
    Args:
        event: The event to convert to ICS
        
    Returns:
        The ICS file content as a string
    """
    cal = Calendar()
    cal.add('prodid', '-//Polaris Calendar//EN')
    cal.add('version', '2.0')
    
    # Create event
    ical_event = ICalEvent()
    
    if not event.ics_uid:
        event.ics_uid = str(uuid.uuid4())
    
    ical_event.add('uid', event.ics_uid)
    ical_event.add('summary', event.title)
    
    if event.description:
        ical_event.add('description', event.description)
    
    if event.is_all_day:
        # All-day events need date without time
        ical_event.add('dtstart', event.start_time.date())
        ical_event.add('dtend', event.end_time.date())
    else:
        # Regular events include time
        ical_event.add('dtstart', event.start_time)
        ical_event.add('dtend', event.end_time)
    
    if event.location:
        ical_event.add('location', event.location)
    
    # Add reminders as alarms
    for reminder in event.reminders:
        alarm = ical_event.add('valarm')
        alarm.add('action', 'DISPLAY')
        alarm.add('description', f'Reminder: {event.title}')
        alarm.add('trigger', timedelta(minutes=-reminder.minutes_before))
    
    # Add tag information as categories
    if event.tags:
        categories = [tag.name for tag in event.tags]
        if categories:
            ical_event.add('categories', categories)
    
    ical_event.add('dtstamp', datetime.utcnow())
    ical_event.add('created', event.created_at)
    ical_event.add('last-modified', event.updated_at)
    
    cal.add_component(ical_event)
    
    return cal.to_ical().decode('utf-8')

def export_event_to_ics(event: Event) -> str:
    """
    Export an event to ICS format
    
    Args:
        event: The event to export
        
    Returns:
        The ICS file content as a string
    """
    return create_ics_file(event)

def import_ics_file(ics_content: bytes, user_id: int, db) -> List[Event]:
    """
    Import events from an ICS file
    
    Args:
        ics_content: The ICS file content
        user_id: The ID of the user importing the events
        db: Database session
        
    Returns:
        List of created events
    """
    try:
        calendar = Calendar.from_ical(ics_content)
        imported_events = []
        
        for component in calendar.walk():
            if component.name == "VEVENT":
                # Extract event details
                summary = str(component.get('summary', 'Untitled Event'))
                description = str(component.get('description', ''))
                
                # Handle start and end times
                dtstart = component.get('dtstart').dt
                dtend = component.get('dtend').dt if component.get('dtend') else dtstart + timedelta(hours=1)
                
                # Check if this is an all-day event (date without time)
                is_all_day = isinstance(dtstart, datetime.date) and not isinstance(dtstart, datetime)
                
                # Convert to datetime if needed
                if is_all_day:
                    # Convert date to datetime at start of day
                    start_time = datetime.combine(dtstart, datetime.min.time())
                    end_time = datetime.combine(dtend, datetime.min.time())
                else:
                    start_time = dtstart
                    end_time = dtend
                
                # Make sure we have naive datetimes
                if hasattr(start_time, 'tzinfo') and start_time.tzinfo:
                    start_time = start_time.astimezone(pytz.utc).replace(tzinfo=None)
                if hasattr(end_time, 'tzinfo') and end_time.tzinfo:
                    end_time = end_time.astimezone(pytz.utc).replace(tzinfo=None)
                
                location = str(component.get('location', ''))
                uid = str(component.get('uid', str(uuid.uuid4())))
                
                # Check if event with this UID already exists
                existing_event = db.query(Event).filter(Event.ics_uid == uid, Event.user_id == user_id).first()
                if existing_event:
                    # Update existing event
                    existing_event.title = summary
                    existing_event.description = description
                    existing_event.start_time = start_time
                    existing_event.end_time = end_time
                    existing_event.location = location
                    existing_event.is_all_day = is_all_day
                    existing_event.updated_at = datetime.utcnow()
                    
                    # Process categories/tags
                    categories = component.get('categories', [])
                    if categories:
                        if isinstance(categories, str):
                            categories = [categories]
                        for category in categories:
                            tag_name = str(category)
                            # Check if tag exists
                            tag = db.query(Tag).filter(Tag.name == tag_name, Tag.user_id == user_id).first()
                            if not tag:
                                # Create new tag
                                tag = Tag(name=tag_name, user_id=user_id)
                                db.add(tag)
                                db.commit()
                            
                            # Add tag to event if not already present
                            if tag not in existing_event.tags:
                                existing_event.tags.append(tag)
                    
                    # Process alarms/reminders
                    # First, remove existing reminders
                    db.query(Reminder).filter(Reminder.event_id == existing_event.id).delete()
                    
                    # Add new reminders from alarms
                    for alarm in component.walk('VALARM'):
                        if alarm.get('action') == 'DISPLAY':
                            trigger = alarm.get('trigger')
                            if trigger and hasattr(trigger, 'dt'):
                                # Calculate minutes before
                                if isinstance(trigger.dt, timedelta):
                                    minutes_before = abs(int(trigger.dt.total_seconds() / 60))
                                    reminder = Reminder(minutes_before=minutes_before, event_id=existing_event.id)
                                    db.add(reminder)
                    
                    db.commit()
                    imported_events.append(existing_event)
                else:
                    # Create new event
                    new_event = Event(
                        title=summary,
                        description=description,
                        start_time=start_time,
                        end_time=end_time,
                        location=location,
                        is_all_day=is_all_day,
                        ics_uid=uid,
                        user_id=user_id
                    )
                    db.add(new_event)
                    db.commit()
                    db.refresh(new_event)
                    
                    # Process categories/tags
                    categories = component.get('categories', [])
                    if categories:
                        if isinstance(categories, str):
                            categories = [categories]
                        for category in categories:
                            tag_name = str(category)
                            # Check if tag exists
                            tag = db.query(Tag).filter(Tag.name == tag_name, Tag.user_id == user_id).first()
                            if not tag:
                                # Create new tag
                                tag = Tag(name=tag_name, user_id=user_id)
                                db.add(tag)
                                db.commit()
                            
                            # Add tag to event
                            new_event.tags.append(tag)
                    
                    # Process alarms/reminders
                    for alarm in component.walk('VALARM'):
                        if alarm.get('action') == 'DISPLAY':
                            trigger = alarm.get('trigger')
                            if trigger and hasattr(trigger, 'dt'):
                                # Calculate minutes before
                                if isinstance(trigger.dt, timedelta):
                                    minutes_before = abs(int(trigger.dt.total_seconds() / 60))
                                    reminder = Reminder(minutes_before=minutes_before, event_id=new_event.id)
                                    db.add(reminder)
                    
                    db.commit()
                    db.refresh(new_event)
                    imported_events.append(new_event)
        
        return imported_events
    except Exception as e:
        # Log the error and raise it
        print(f"Error importing ICS file: {str(e)}")
        raise 