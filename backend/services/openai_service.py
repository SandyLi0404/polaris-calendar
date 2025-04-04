import openai
import base64
import json
from typing import Tuple, List, Dict, Any, Optional
from io import BytesIO
from datetime import datetime, timedelta

from utils.config import settings

# Configure OpenAI
openai.api_key = settings.OPENAI_API_KEY

async def process_chat_message(message: str, user_id: int, db) -> Tuple[str, Optional[List[Dict[str, Any]]]]:
    """
    Process a chat message and extract potential todo items or calendar events
    
    Args:
        message: The user's message
        user_id: The ID of the user
        db: Database session
        
    Returns:
        Tuple containing (chatbot response, list of generated items)
    """
    try:
        # Create the system message with instructions
        system_message = """
        You are an AI assistant for Polaris Calendar, a calendar and todo app. 
        Your job is to help users manage their schedule and tasks.
        
        If the user's message contains information about:
        1. A task or todo item - Extract it and format it as a todo item
        2. An event or meeting - Extract it and format it as a calendar event
        
        Respond conversationally, and if you detect a task or event, include it in JSON format in your thinking.
        """
        
        # Create the conversation
        response = await openai.ChatCompletion.acreate(
            model="gpt-4",
            messages=[
                {"role": "system", "content": system_message},
                {"role": "user", "content": message}
            ],
            temperature=0.7,
            functions=[
                {
                    "name": "extract_todo_item",
                    "description": "Extract a todo item from the user message",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "title": {"type": "string", "description": "The title of the todo item"},
                            "description": {"type": "string", "description": "Optional description"},
                            "deadline": {"type": "string", "description": "The deadline in ISO format (YYYY-MM-DD)"},
                            "priority": {"type": "string", "enum": ["high", "low"], "description": "Priority level"}
                        },
                        "required": ["title"]
                    }
                },
                {
                    "name": "extract_calendar_event",
                    "description": "Extract a calendar event from the user message",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "title": {"type": "string", "description": "The title of the event"},
                            "description": {"type": "string", "description": "Optional description"},
                            "start_time": {"type": "string", "description": "The start time in ISO format (YYYY-MM-DDTHH:MM:SS)"},
                            "end_time": {"type": "string", "description": "The end time in ISO format (YYYY-MM-DDTHH:MM:SS)"},
                            "location": {"type": "string", "description": "Optional location"},
                            "is_all_day": {"type": "boolean", "description": "Whether this is an all-day event"}
                        },
                        "required": ["title", "start_time"]
                    }
                }
            ],
            function_call="auto"
        )
        
        # Extract response
        choice = response.choices[0]
        response_message = choice.message
        
        # Check if a function was called
        generated_items = []
        if hasattr(response_message, 'function_call') and response_message.function_call:
            function_call = response_message.function_call
            
            # Extract the function call results
            function_name = function_call.name
            function_args = json.loads(function_call.arguments)
            
            if function_name == "extract_todo_item":
                # Format as todo item
                generated_items.append({
                    "type": "todo",
                    "data": function_args
                })
                
                # Get a user-friendly response
                clarification_response = await openai.ChatCompletion.acreate(
                    model="gpt-4",
                    messages=[
                        {"role": "system", "content": system_message},
                        {"role": "user", "content": message},
                        {"role": "assistant", "content": "I've identified a todo item in your message."},
                        {"role": "user", "content": "Can you describe this todo item in a user-friendly way and ask me if I want to add it to my todo list?"}
                    ],
                    temperature=0.7
                )
                
                bot_response = clarification_response.choices[0].message.content
            
            elif function_name == "extract_calendar_event":
                # Format as calendar event
                generated_items.append({
                    "type": "event",
                    "data": function_args
                })
                
                # Get a user-friendly response
                clarification_response = await openai.ChatCompletion.acreate(
                    model="gpt-4",
                    messages=[
                        {"role": "system", "content": system_message},
                        {"role": "user", "content": message},
                        {"role": "assistant", "content": "I've identified a calendar event in your message."},
                        {"role": "user", "content": "Can you describe this event in a user-friendly way and ask me if I want to add it to my calendar?"}
                    ],
                    temperature=0.7
                )
                
                bot_response = clarification_response.choices[0].message.content
            else:
                bot_response = response_message.content
        else:
            bot_response = response_message.content
        
        return bot_response, generated_items if generated_items else None
    
    except Exception as e:
        print(f"Error processing chat message: {str(e)}")
        return f"I'm sorry, I encountered an error: {str(e)}", None

async def process_image(image_data: bytes, prompt: str, user_id: int, db) -> Tuple[str, Optional[List[Dict[str, Any]]]]:
    """
    Process an image and extract information based on the prompt
    
    Args:
        image_data: Raw image data
        prompt: The user's prompt
        user_id: The ID of the user
        db: Database session
        
    Returns:
        Tuple containing (chatbot response, list of generated items)
    """
    try:
        # Encode image to base64
        base64_image = base64.b64encode(image_data).decode('utf-8')
        
        # Create the system message with instructions
        system_message = """
        You are an AI assistant for Polaris Calendar, a calendar and todo app. 
        You can analyze images and extract relevant information from them.
        
        If the image contains information about:
        1. A task or todo item - Extract it and format it as a todo item
        2. An event or meeting - Extract it and format it as a calendar event
        3. A schedule or timetable - Extract events and format them as calendar events
        
        Respond conversationally, and if you detect tasks or events, include them in JSON format in your thinking.
        """
        
        # Create the conversation with the image
        response = await openai.ChatCompletion.acreate(
            model="gpt-4-vision-preview",
            messages=[
                {"role": "system", "content": system_message},
                {
                    "role": "user", 
                    "content": [
                        {"type": "text", "text": prompt},
                        {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}
                    ]
                }
            ],
            max_tokens=500
        )
        
        # Extract response
        bot_response = response.choices[0].message.content
        
        # Now try to extract structured data if it exists in the response
        extraction_prompt = f"""
        Original image analysis: {bot_response}
        
        Based on the above analysis, extract any todo items or calendar events mentioned.
        If there are none, return an empty array.
        """
        
        extraction_response = await openai.ChatCompletion.acreate(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You extract structured data from text."},
                {"role": "user", "content": extraction_prompt}
            ],
            functions=[
                {
                    "name": "extract_items",
                    "description": "Extract todo items and calendar events",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "todo_items": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "title": {"type": "string"},
                                        "description": {"type": "string"},
                                        "deadline": {"type": "string"},
                                        "priority": {"type": "string", "enum": ["high", "low"]}
                                    },
                                    "required": ["title"]
                                }
                            },
                            "calendar_events": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "title": {"type": "string"},
                                        "description": {"type": "string"},
                                        "start_time": {"type": "string"},
                                        "end_time": {"type": "string"},
                                        "location": {"type": "string"},
                                        "is_all_day": {"type": "boolean"}
                                    },
                                    "required": ["title", "start_time"]
                                }
                            }
                        }
                    }
                }
            ],
            function_call={"name": "extract_items"}
        )
        
        # Check if items were extracted
        generated_items = []
        if hasattr(extraction_response.choices[0].message, 'function_call'):
            function_args = json.loads(extraction_response.choices[0].message.function_call.arguments)
            
            # Process todo items
            for item in function_args.get("todo_items", []):
                generated_items.append({
                    "type": "todo",
                    "data": item
                })
            
            # Process calendar events
            for event in function_args.get("calendar_events", []):
                generated_items.append({
                    "type": "event",
                    "data": event
                })
        
        return bot_response, generated_items if generated_items else None
    
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        return f"I'm sorry, I encountered an error processing your image: {str(e)}", None

async def transcribe_audio(audio_file_path: str) -> str:
    """
    Transcribe audio file to text
    
    Args:
        audio_file_path: Path to the audio file
        
    Returns:
        Transcribed text
    """
    try:
        with open(audio_file_path, "rb") as audio_file:
            transcript = await openai.Audio.atranscribe("whisper-1", audio_file)
        
        return transcript.text
    except Exception as e:
        print(f"Error transcribing audio: {str(e)}")
        return "" 