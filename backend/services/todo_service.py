from datetime import datetime
from typing import Dict, Any
import dateutil.parser

from models.todo import TodoItem, TodoReminder, PriorityLevel

def create_todo_from_text(todo_data: Dict[str, Any], user_id: int, db) -> TodoItem:
    """
    Create a todo item from structured data extracted from text
    
    Args:
        todo_data: Dictionary containing todo item data
        user_id: The ID of the user
        db: Database session
        
    Returns:
        The created TodoItem
    """
    # Extract fields from data
    title = todo_data.get("title", "Untitled Todo")
    description = todo_data.get("description", "")
    
    # Parse deadline if provided
    deadline = None
    if todo_data.get("deadline"):
        try:
            deadline = dateutil.parser.parse(todo_data["deadline"])
        except:
            # If parsing fails, leave as None
            pass
    
    # Get priority
    priority_str = todo_data.get("priority", "low").lower()
    priority = PriorityLevel.HIGH if priority_str == "high" else PriorityLevel.LOW
    
    # Create todo item
    todo_item = TodoItem(
        title=title,
        description=description,
        deadline=deadline,
        priority=priority,
        user_id=user_id
    )
    
    db.add(todo_item)
    db.commit()
    db.refresh(todo_item)
    
    # Add a default reminder if there's a deadline
    if deadline:
        reminder = TodoReminder(
            minutes_before=60,  # Default to 1 hour before
            todo_item_id=todo_item.id
        )
        db.add(reminder)
        db.commit()
    
    return todo_item 