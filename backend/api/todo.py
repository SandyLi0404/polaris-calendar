from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
from enum import Enum
from pydantic import BaseModel

from utils.database import get_db
from utils.auth import get_current_active_user
from models.user import User
from models.todo import TodoItem, TodoReminder, PriorityLevel

router = APIRouter()

# Pydantic models for request/response
class TodoReminderCreate(BaseModel):
    minutes_before: int = 60
    
    class Config:
        orm_mode = True

class TodoReminderResponse(BaseModel):
    id: int
    minutes_before: int
    is_sent: bool
    
    class Config:
        orm_mode = True

class TodoItemCreate(BaseModel):
    title: str
    description: Optional[str] = None
    deadline: Optional[datetime] = None
    priority: PriorityLevel = PriorityLevel.LOW
    reminders: List[TodoReminderCreate] = [TodoReminderCreate()]
    
    class Config:
        orm_mode = True

class TodoItemResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    deadline: Optional[datetime] = None
    is_completed: bool
    priority: PriorityLevel
    created_at: datetime
    updated_at: datetime
    reminders: List[TodoReminderResponse] = []
    
    class Config:
        orm_mode = True

class SortOrder(str, Enum):
    ALPHABETICAL = "alphabetical"
    DEADLINE = "deadline"
    PRIORITY = "priority"
    CREATED = "created"

@router.get("/items", response_model=List[TodoItemResponse])
async def get_todo_items(
    completed: Optional[bool] = Query(None),
    sort_by: Optional[SortOrder] = Query(SortOrder.CREATED),
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    query = db.query(TodoItem).filter(TodoItem.user_id == user_id)
    
    # Filter by completion status
    if completed is not None:
        query = query.filter(TodoItem.is_completed == completed)
    
    # Sort
    if sort_by == SortOrder.ALPHABETICAL:
        query = query.order_by(TodoItem.title)
    elif sort_by == SortOrder.DEADLINE:
        # Handle null deadlines (put them at the end)
        query = query.order_by(TodoItem.deadline.is_(None), TodoItem.deadline)
    elif sort_by == SortOrder.PRIORITY:
        # High priority first
        query = query.order_by(TodoItem.priority.desc())
    else:  # CREATED (default)
        query = query.order_by(TodoItem.created_at.desc())
    
    return query.all()

@router.get("/items/today", response_model=List[TodoItemResponse])
async def get_today_todo_items(
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    # Get today's date (without time)
    today = datetime.now().date()
    tomorrow = today + timedelta(days=1)
    
    # Query items with deadline today or no deadline but created today
    query = db.query(TodoItem).filter(
        TodoItem.user_id == user_id,
        (
            (TodoItem.deadline >= today) & 
            (TodoItem.deadline < tomorrow)
        ) | 
        (
            (TodoItem.created_at >= today) & 
            (TodoItem.created_at < tomorrow) &
            (TodoItem.deadline.is_(None))
        )
    )
    
    return query.all()

@router.get("/items/{todo_id}", response_model=TodoItemResponse)
async def get_todo_item(
    todo_id: int,
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    todo_item = db.query(TodoItem).filter(
        TodoItem.id == todo_id,
        TodoItem.user_id == user_id
    ).first()
    
    if not todo_item:
        raise HTTPException(status_code=404, detail="Todo item not found")
    
    return todo_item

@router.post("/items", response_model=TodoItemResponse)
async def create_todo_item(
    todo_item: TodoItemCreate,
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    # Create new todo item
    db_todo_item = TodoItem(
        title=todo_item.title,
        description=todo_item.description,
        deadline=todo_item.deadline,
        priority=todo_item.priority,
        user_id=user_id
    )
    
    db.add(db_todo_item)
    db.commit()
    db.refresh(db_todo_item)
    
    # Add reminders
    for reminder_data in todo_item.reminders:
        reminder = TodoReminder(
            minutes_before=reminder_data.minutes_before,
            todo_item_id=db_todo_item.id
        )
        db.add(reminder)
    
    db.commit()
    db.refresh(db_todo_item)
    
    return db_todo_item

@router.put("/items/{todo_id}", response_model=TodoItemResponse)
async def update_todo_item(
    todo_id: int,
    todo_data: TodoItemCreate,
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    # Get todo item
    todo_item = db.query(TodoItem).filter(
        TodoItem.id == todo_id,
        TodoItem.user_id == user_id
    ).first()
    
    if not todo_item:
        raise HTTPException(status_code=404, detail="Todo item not found")
    
    # Update todo item fields
    todo_item.title = todo_data.title
    todo_item.description = todo_data.description
    todo_item.deadline = todo_data.deadline
    todo_item.priority = todo_data.priority
    
    # Update reminders
    # Delete existing reminders
    db.query(TodoReminder).filter(TodoReminder.todo_item_id == todo_item.id).delete()
    
    # Add new reminders
    for reminder_data in todo_data.reminders:
        reminder = TodoReminder(
            minutes_before=reminder_data.minutes_before,
            todo_item_id=todo_item.id
        )
        db.add(reminder)
    
    db.commit()
    db.refresh(todo_item)
    
    return todo_item

@router.patch("/items/{todo_id}/toggle", response_model=TodoItemResponse)
async def toggle_todo_completion(
    todo_id: int,
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    # Get todo item
    todo_item = db.query(TodoItem).filter(
        TodoItem.id == todo_id,
        TodoItem.user_id == user_id
    ).first()
    
    if not todo_item:
        raise HTTPException(status_code=404, detail="Todo item not found")
    
    # Toggle completion status
    todo_item.is_completed = not todo_item.is_completed
    
    db.commit()
    db.refresh(todo_item)
    
    return todo_item

@router.delete("/items/{todo_id}", response_model=dict)
async def delete_todo_item(
    todo_id: int,
    current_user: Optional[User] = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # For development, if user is not authenticated, use a fixed user ID
    user_id = current_user.id if current_user else 1
    
    # Get todo item
    todo_item = db.query(TodoItem).filter(
        TodoItem.id == todo_id,
        TodoItem.user_id == user_id
    ).first()
    
    if not todo_item:
        raise HTTPException(status_code=404, detail="Todo item not found")
    
    # Delete todo item
    db.delete(todo_item)
    db.commit()
    
    return {"message": "Todo item deleted successfully"} 