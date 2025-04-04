from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models.user import User
from models.calendar import Event, Tag, Reminder
from models.todo import TodoItem, TodoReminder, PriorityLevel
from utils.database import Base, get_db
from utils.auth import get_password_hash
from datetime import datetime, timedelta
import uuid

# Create tables
def init_db():
    from utils.database import SQLALCHEMY_DATABASE_URL, engine
    Base.metadata.create_all(bind=engine)
    print("Database tables created.")

# Create sample data
def create_sample_data():
    from utils.database import SessionLocal
    db = SessionLocal()
    
    try:
        # Check if we already have users
        user_count = db.query(User).count()
        if user_count > 0:
            print("Sample data already exists.")
            return
        
        # Create a sample user
        sample_user = User(
            username="sample",
            email="sample@example.com",
            hashed_password=get_password_hash("password"),
            full_name="Sample User",
            executive_summary_time="07:00",
            is_active=True
        )
        db.add(sample_user)
        db.commit()
        db.refresh(sample_user)
        
        print(f"Created sample user: {sample_user.username}")
        
        # Create some tags
        tags = []
        for tag_data in [
            {"name": "Work", "color": "#e74c3c"},  # Red
            {"name": "Personal", "color": "#3498db"},  # Blue
            {"name": "Health", "color": "#2ecc71"},  # Green
            {"name": "Family", "color": "#9b59b6"},  # Purple
            {"name": "Shopping", "color": "#f39c12"}  # Orange
        ]:
            tag = Tag(
                name=tag_data["name"],
                color=tag_data["color"],
                user_id=sample_user.id
            )
            db.add(tag)
            tags.append(tag)
        
        db.commit()
        print(f"Created {len(tags)} sample tags")
        
        # Create some calendar events
        now = datetime.now()
        events = []
        
        # Today's event
        today_event = Event(
            title="Team Meeting",
            description="Weekly team sync",
            start_time=now.replace(hour=14, minute=0, second=0, microsecond=0),
            end_time=now.replace(hour=15, minute=0, second=0, microsecond=0),
            location="Conference Room A",
            is_all_day=False,
            ics_uid=str(uuid.uuid4()),
            user_id=sample_user.id
        )
        today_event.tags = [tags[0]]  # Work tag
        db.add(today_event)
        events.append(today_event)
        
        # Tomorrow's event
        tomorrow = now + timedelta(days=1)
        tomorrow_event = Event(
            title="Doctor Appointment",
            description="Annual checkup",
            start_time=tomorrow.replace(hour=10, minute=0, second=0, microsecond=0),
            end_time=tomorrow.replace(hour=11, minute=0, second=0, microsecond=0),
            location="Downtown Clinic",
            is_all_day=False,
            ics_uid=str(uuid.uuid4()),
            user_id=sample_user.id
        )
        tomorrow_event.tags = [tags[2]]  # Health tag
        db.add(tomorrow_event)
        events.append(tomorrow_event)
        
        # All-day event next week
        next_week = now + timedelta(days=7)
        allday_event = Event(
            title="Family Reunion",
            description="Annual family gathering",
            start_time=next_week.replace(hour=0, minute=0, second=0, microsecond=0),
            end_time=(next_week + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0),
            location="City Park",
            is_all_day=True,
            ics_uid=str(uuid.uuid4()),
            user_id=sample_user.id
        )
        allday_event.tags = [tags[3]]  # Family tag
        db.add(allday_event)
        events.append(allday_event)
        
        db.commit()
        print(f"Created {len(events)} sample events")
        
        # Add reminders to events
        for event in events:
            reminder = Reminder(
                minutes_before=15,
                event_id=event.id
            )
            db.add(reminder)
        
        db.commit()
        print("Added reminders to events")
        
        # Create todo items
        todo_items = []
        
        # Create some todo items
        todo1 = TodoItem(
            title="Buy groceries",
            description="Milk, eggs, bread, vegetables",
            deadline=now.replace(hour=18, minute=0, second=0, microsecond=0),
            priority=PriorityLevel.HIGH,
            is_completed=False,
            user_id=sample_user.id
        )
        db.add(todo1)
        todo_items.append(todo1)
        
        todo2 = TodoItem(
            title="Prepare presentation",
            description="For next week's client meeting",
            deadline=(now + timedelta(days=3)).replace(hour=17, minute=0, second=0, microsecond=0),
            priority=PriorityLevel.HIGH,
            is_completed=False,
            user_id=sample_user.id
        )
        db.add(todo2)
        todo_items.append(todo2)
        
        todo3 = TodoItem(
            title="Call mom",
            description="Ask about weekend plans",
            deadline=None,  # No deadline
            priority=PriorityLevel.LOW,
            is_completed=False,
            user_id=sample_user.id
        )
        db.add(todo3)
        todo_items.append(todo3)
        
        todo4 = TodoItem(
            title="Pay utility bills",
            description="Water, electricity, internet",
            deadline=(now + timedelta(days=10)).replace(hour=23, minute=59, second=59, microsecond=0),
            priority=PriorityLevel.HIGH,
            is_completed=False,
            user_id=sample_user.id
        )
        db.add(todo4)
        todo_items.append(todo4)
        
        db.commit()
        print(f"Created {len(todo_items)} sample todo items")
        
        # Add reminders to todo items with deadlines
        for todo in todo_items:
            if todo.deadline:
                reminder = TodoReminder(
                    minutes_before=60,
                    todo_item_id=todo.id
                )
                db.add(reminder)
        
        db.commit()
        print("Added reminders to todo items")
        
    except Exception as e:
        print(f"Error creating sample data: {str(e)}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("Initializing database...")
    init_db()
    print("Creating sample data...")
    create_sample_data()
    print("Done!") 