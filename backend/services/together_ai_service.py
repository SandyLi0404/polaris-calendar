import json
import together
from typing import Tuple, List, Dict, Any, Optional
from datetime import datetime, timedelta

from utils.config import settings

MODEL_NAME = "meta-llama/Llama-3.3-70B-Instruct-Turbo"

async def process_chat_message(
    message: str, 
    user_id: int, 
    db, 
    conversation_history: Optional[List[Dict[str, str]]] = None
) -> Tuple[str, Optional[List[Dict[str, Any]]]]:
    """
    Process a chat message using Together AI LLM (Llama 3 model)
    
    Args:
        message: The user's message
        user_id: The ID of the user
        db: Database session
        conversation_history: List of previous messages in the conversation
        
    Returns:
        Tuple containing (chatbot response, list of generated items)
    """
    try:
        # Debug log to check API key
        api_key = settings.TOGETHER_API_KEY
        if not api_key:
            print("WARNING: Together API key is not set!")
            return "I'm sorry, the AI service is not properly configured. Please contact the administrator.", None
        else:
            masked_key = api_key[:4] + "..." + api_key[-4:] if len(api_key) > 8 else "***"
            print(f"Using Together API key: {masked_key}")
        
        # Create the system message with instructions
        system_message = """
        You are an AI assistant for Polaris Calendar, a calendar and todo app. 
        Your job is to help users manage their schedule and tasks.
        
        If the user's message contains information about:
        1. A task or todo item - Extract it and format it as a todo item
        2. An event or meeting - Extract it and format it as a calendar event
        
        Remember previous messages in the conversation when responding.
        Respond conversationally and be helpful.
        """
        
        # Create Together client
        client = together.Together(api_key=api_key)
        
        # Set up tools for function calling
        tools = [
            {
                "type": "function",
                "function": {
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
                }
            },
            {
                "type": "function",
                "function": {
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
            }
        ]
        
        # Make the API call using the SDK
        try:
            print(f"Sending request to Together AI...")
            
            # Prepare messages list
            messages = [{"role": "system", "content": system_message}]
            
            # Include conversation history if provided
            if conversation_history and len(conversation_history) > 0:
                # Use conversation history but limit to last 10 exchanges
                # Skip adding the current message since it will be added below
                history = conversation_history[:-1] if len(conversation_history) > 0 and conversation_history[-1]["role"] == "user" else conversation_history
                # Take only the last 10 messages to avoid context window limits
                messages.extend(history[-10:])
            else:
                # If no history, just add the current user message
                messages.append({"role": "user", "content": message})
            
            # Make sure the most recent user message is included
            if not conversation_history or messages[-1]["role"] != "user" or messages[-1]["content"] != message:
                messages.append({"role": "user", "content": message})
            
            # Log the conversation context being sent
            print(f"Sending conversation with {len(messages)} messages")
            
            completion = client.chat.completions.create(
                model=MODEL_NAME,
                messages=messages,
                temperature=0.7,
                tools=tools,
                tool_choice="auto"
            )
            
            print(f"Got response from Together AI")
            
            # Extract the response message
            response_message = completion.choices[0].message
            
            # Check if a tool was called
            generated_items = []
            if hasattr(response_message, 'tool_calls') and response_message.tool_calls:
                tool_call = response_message.tool_calls[0]
                print(f"Tool call detected: {tool_call.function.name}")
                
                # Extract the function call results
                function_name = tool_call.function.name
                function_args = json.loads(tool_call.function.arguments)
                
                if function_name == "extract_todo_item":
                    # Format as todo item
                    generated_items.append({
                        "type": "todo",
                        "data": function_args
                    })
                    
                    # Get a user-friendly response with a follow-up call
                    clarification_messages = messages.copy()
                    clarification_messages.append({"role": "assistant", "content": "I've identified a todo item in your message."})
                    clarification_messages.append({"role": "user", "content": "Can you acknowledge this todo item in a natural, conversational way? Only ask if I want to add it when that's clearly appropriate based on context."})
                    
                    clarification_completion = client.chat.completions.create(
                        model=MODEL_NAME,
                        messages=clarification_messages,
                        temperature=0.7
                    )
                    
                    bot_response = clarification_completion.choices[0].message.content
                
                elif function_name == "extract_calendar_event":
                    # Format as calendar event
                    generated_items.append({
                        "type": "event",
                        "data": function_args
                    })
                    
                    # Get a user-friendly response with a follow-up call
                    clarification_messages = messages.copy()
                    clarification_messages.append({"role": "assistant", "content": "I've identified a calendar event in your message."})
                    clarification_messages.append({"role": "user", "content": "Can you acknowledge this event in a natural, conversational way? Only ask if I want to add it when that's clearly appropriate based on context."})
                    
                    clarification_completion = client.chat.completions.create(
                        model=MODEL_NAME,
                        messages=clarification_messages,
                        temperature=0.7
                    )
                    
                    bot_response = clarification_completion.choices[0].message.content
                else:
                    bot_response = response_message.content or "I've processed your request but couldn't generate a proper response."
            else:
                bot_response = response_message.content or "I couldn't understand your request. Please try rephrasing."
        except Exception as e:
            print(f"API request error: {str(e)}")
            # Provide a simple response if API call failed
            return f"I'm having trouble connecting to the AI service. Error: {str(e)}", None
        
        return bot_response, generated_items if generated_items else None
    
    except Exception as e:
        print(f"Error processing chat message: {str(e)}")
        return f"I'm sorry, I encountered an error: {str(e)}", None 