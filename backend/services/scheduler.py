import schedule
import time
import threading
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from utils.database import SessionLocal
from utils.config import settings
from models.calendar import Event, Reminder
from models.todo import TodoItem, TodoReminder
from models.user import User

def check_event_reminders():
    """Check for event reminders that need to be sent"""
    db = SessionLocal()
    try:
        # Get current time
        now = datetime.utcnow()
        
        # Find unsent reminders where the event start time minus reminder minutes is within the next minute
        reminders = db.query(Reminder).filter(
            Reminder.is_sent == False
        ).join(Event).filter(
            Event.start_time > now,  # Event hasn't started yet
            Event.start_time <= now + timedelta(minutes=5)  # Event is within the next 5 minutes (batch check)
        ).all()
        
        for reminder in reminders:
            event = reminder.event
            reminder_time = event.start_time - timedelta(minutes=reminder.minutes_before)
            
            # If it's time to send the reminder
            if reminder_time <= now:
                # Here we would integrate with a notification service
                # For now, just mark as sent
                print(f"Sending reminder for event: {event.title} - starts at {event.start_time}")
                reminder.is_sent = True
                db.commit()
        
    finally:
        db.close()

def check_todo_reminders():
    """Check for todo reminders that need to be sent"""
    db = SessionLocal()
    try:
        # Get current time
        now = datetime.utcnow()
        
        # Find unsent reminders where the todo deadline minus reminder minutes is within the next minute
        reminders = db.query(TodoReminder).filter(
            TodoReminder.is_sent == False
        ).join(TodoItem).filter(
            TodoItem.deadline > now,  # Todo hasn't passed deadline yet
            TodoItem.deadline <= now + timedelta(minutes=5),  # Todo is due within the next 5 minutes (batch check)
            TodoItem.is_completed == False  # Todo is not completed
        ).all()
        
        for reminder in reminders:
            todo = reminder.todo_item
            reminder_time = todo.deadline - timedelta(minutes=reminder.minutes_before)
            
            # If it's time to send the reminder
            if reminder_time <= now:
                # Here we would integrate with a notification service
                # For now, just mark as sent
                print(f"Sending reminder for todo: {todo.title} - due at {todo.deadline}")
                reminder.is_sent = True
                db.commit()
        
    finally:
        db.close()

def send_daily_summaries():
    """Send daily executive summaries to users"""
    db = SessionLocal()
    try:
        # Get current time
        now = datetime.utcnow()
        current_hour = now.hour
        current_minute = now.minute
        
        # Get users with summary time matching current time
        users = db.query(User).filter(User.is_active == True).all()
        
        for user in users:
            # Parse summary time
            try:
                summary_time = user.executive_summary_time.split(":")
                summary_hour = int(summary_time[0])
                summary_minute = int(summary_time[1] if len(summary_time) > 1 else "0")
                
                # If it's time to send the summary
                if summary_hour == current_hour and summary_minute == current_minute:
                    # Here we would generate and send the summary
                    print(f"Sending daily summary to user: {user.username}")
                    # In a real implementation, this would call the summary service
            except:
                # If parsing fails, just skip this user
                pass
        
    finally:
        db.close()

def scheduler_thread():
    """Thread function for running the scheduler"""
    # Schedule periodic checks
    schedule.every(1).minutes.do(check_event_reminders)
    schedule.every(1).minutes.do(check_todo_reminders)
    schedule.every(1).minutes.do(send_daily_summaries)
    
    # Run the schedule
    while True:
        schedule.run_pending()
        time.sleep(1)

def start_scheduler():
    """Start the scheduler in a separate thread"""
    thread = threading.Thread(target=scheduler_thread)
    thread.daemon = True  # Thread will exit when the main program exits
    thread.start()
    print("Scheduler started") 