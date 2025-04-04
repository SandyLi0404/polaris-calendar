from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Table
from sqlalchemy.orm import relationship
from datetime import datetime

from utils.database import Base

# Association table for event tags
event_tag = Table(
    'event_tag',
    Base.metadata,
    Column('event_id', Integer, ForeignKey('events.id'), primary_key=True),
    Column('tag_id', Integer, ForeignKey('tags.id'), primary_key=True)
)

class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String, nullable=True)
    start_time = Column(DateTime, index=True)
    end_time = Column(DateTime, index=True)
    location = Column(String, nullable=True)
    is_all_day = Column(Boolean, default=False)
    ics_uid = Column(String, unique=True, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship with User
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="events")
    
    # Relationship with Reminder
    reminders = relationship("Reminder", back_populates="event", cascade="all, delete-orphan")
    
    # Relationship with tags
    tags = relationship("Tag", secondary=event_tag, back_populates="events")

class Tag(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, unique=True)
    color = Column(String, default="#3498db")  # Default to blue
    
    # Relationship with events
    events = relationship("Event", secondary=event_tag, back_populates="tags")
    
    # Relationship with User
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="tags")

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)
    minutes_before = Column(Integer, default=15)  # Default to 15 minutes before
    is_sent = Column(Boolean, default=False)
    
    # Relationship with Event
    event_id = Column(Integer, ForeignKey("events.id"))
    event = relationship("Event", back_populates="reminders") 