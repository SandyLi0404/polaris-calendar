from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from utils.database import Base

class PriorityLevel(enum.Enum):
    HIGH = "high"
    LOW = "low"

class TodoItem(Base):
    __tablename__ = "todo_items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String, nullable=True)
    deadline = Column(DateTime, nullable=True, index=True)
    is_completed = Column(Boolean, default=False)
    priority = Column(Enum(PriorityLevel), default=PriorityLevel.LOW)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Add fields for calendar integration
    added_to_calendar = Column(Boolean, default=False)
    event_id = Column(String, nullable=True)
    
    # Relationship with User
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="todo_items")
    
    # Relationship with TodoReminder
    reminders = relationship("TodoReminder", back_populates="todo_item", cascade="all, delete-orphan")

class TodoReminder(Base):
    __tablename__ = "todo_reminders"

    id = Column(Integer, primary_key=True, index=True)
    minutes_before = Column(Integer, default=60)  # Default to 1 hour before
    is_sent = Column(Boolean, default=False)
    
    # Relationship with TodoItem
    todo_item_id = Column(Integer, ForeignKey("todo_items.id"))
    todo_item = relationship("TodoItem", back_populates="reminders") 