from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import openai

from models.user import User
from models.calendar import Event
from models.todo import TodoItem
from utils.config import settings

async def generate_daily_summary(user_id: int, db: Session) -> str:
    """
    Generate a daily executive summary for the user
    
    Args:
        user_id: The ID of the user
        db: Database session
        
    Returns:
        The generated summary as a string
    """
    # Get today's date
    today = datetime.now().date()
    tomorrow = today + timedelta(days=1)
    
    # Get user
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return "User not found"
    
    # Get today's events
    events = db.query(Event).filter(
        Event.user_id == user_id,
        Event.start_time >= today,
        Event.start_time < tomorrow
    ).order_by(Event.start_time).all()
    
    # Get incomplete todo items
    todo_items = db.query(TodoItem).filter(
        TodoItem.user_id == user_id,
        TodoItem.is_completed == False
    ).order_by(TodoItem.deadline).all()
    
    # Get todo items with deadline today
    today_todo_items = [item for item in todo_items if item.deadline and item.deadline.date() == today]
    
    # Get overdue todo items
    overdue_todo_items = [item for item in todo_items if item.deadline and item.deadline.date() < today]
    
    # Get upcoming todo items (next 7 days)
    next_week = today + timedelta(days=7)
    upcoming_todo_items = [
        item for item in todo_items 
        if item.deadline and item.deadline.date() > today and item.deadline.date() <= next_week
    ]
    
    # Create summary content
    summary_content = f"Good morning! Here's your summary for {today.strftime('%A, %B %d, %Y')}:\n\n"
    
    # Add events section
    if events:
        summary_content += "Today's Events:\n"
        for event in events:
            time_str = event.start_time.strftime('%I:%M %p') if not event.is_all_day else "All day"
            summary_content += f"- {time_str}: {event.title}"
            if event.location:
                summary_content += f" at {event.location}"
            summary_content += "\n"
    else:
        summary_content += "You have no events scheduled for today.\n"
    
    summary_content += "\n"
    
    # Add todo items section
    if today_todo_items:
        summary_content += "Today's Tasks:\n"
        for item in today_todo_items:
            priority_str = "⚠️ " if item.priority.value == "high" else ""
            summary_content += f"- {priority_str}{item.title}\n"
        summary_content += "\n"
    
    if overdue_todo_items:
        summary_content += "Overdue Tasks:\n"
        for item in overdue_todo_items:
            deadline_str = item.deadline.strftime('%m/%d/%Y') if item.deadline else "No deadline"
            priority_str = "⚠️ " if item.priority.value == "high" else ""
            summary_content += f"- {priority_str}{item.title} (Due: {deadline_str})\n"
        summary_content += "\n"
    
    if upcoming_todo_items:
        summary_content += "Upcoming Tasks:\n"
        for item in upcoming_todo_items:
            deadline_str = item.deadline.strftime('%m/%d/%Y') if item.deadline else "No deadline"
            priority_str = "⚠️ " if item.priority.value == "high" else ""
            summary_content += f"- {priority_str}{item.title} (Due: {deadline_str})\n"
        summary_content += "\n"
    
    # Use OpenAI to generate a more natural-sounding summary
    if settings.OPENAI_API_KEY:
        try:
            response = await openai.ChatCompletion.acreate(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": "You are an executive assistant creating a daily summary. Keep it professional, concise, and organized."},
                    {"role": "user", "content": f"Rewrite this daily summary in a friendly, motivational tone. Don't add any fictional information, just rephrase what's here:\n\n{summary_content}"}
                ],
                temperature=0.7,
                max_tokens=1000
            )
            
            enhanced_summary = response.choices[0].message.content
            return enhanced_summary
        except Exception as e:
            print(f"Error generating enhanced summary: {str(e)}")
            return summary_content
    else:
        return summary_content 