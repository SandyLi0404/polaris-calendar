import json
import together
from typing import Tuple, List, Dict, Any, Optional
from datetime import datetime, timedelta
import traceback

from utils.config import settings

async def process_chat_message(message: str, user_id: int, db) -> Tuple[str, Optional[List[Dict[str, Any]]]]:
    """
    Process a chat message using Together AI LLM (Llama 3 model)
    
    Args:
        message: The user's message
        user_id: The ID of the user
        db: Database session
        
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
            print(f"Using Together API key: {masked_key}, length: {len(api_key)}")
        
        # Create the system message with instructions
        system_message = """
        You are an AI assistant for Polaris Calendar, a calendar and todo app. 
        Your job is to help users manage their schedule and tasks.
        
        If the user's message contains information about:
        1. A task or todo item - Extract it and format it as a todo item
        2. An event or meeting - Extract it and format it as a calendar event
        
        Respond conversationally and be helpful.
        """
        
        # Create Together client with detailed debugging
        print(f"Creating Together client with key of length {len(api_key)}")
        try:
            client = together.Together(api_key=api_key)
            print("Together client created successfully")
        except Exception as e:
            print(f"Error creating Together client: {str(e)}")
            return f"Error initializing AI service: {str(e)}", None
        
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
        
        # Make the API call using the SDK with detailed error handling
        try:
            print(f"Sending request to Together AI with message: '{message[:50]}...'")
            
            # First try a simple text completion to verify API key works
            try:
                test_completion = client.chat.completions.create(
                    model="meta-llama/Llama-3.1-8B-Instruct",
                    messages=[
                        {"role": "user", "content": "Test message"}
                    ],
                    max_tokens=5
                )
                print("API key test successful")
            except Exception as e:
                print(f"API key test failed: {str(e)}")
                print(traceback.format_exc())
                return f"Error testing API connection: {str(e)}", None
            
            # Now try the full completion with tools
            completion = client.chat.completions.create(
                model="meta-llama/Llama-3.1-8B-Instruct",
                messages=[
                    {"role": "system", "content": system_message},
                    {"role": "user", "content": message}
                ],
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
                    clarification_completion = client.chat.completions.create(
                        model="meta-llama/Llama-3.1-8B-Instruct",
                        messages=[
                            {"role": "system", "content": system_message},
                            {"role": "user", "content": message},
                            {"role": "assistant", "content": "I've identified a todo item in your message."},
                            {"role": "user", "content": "Can you describe this todo item in a user-friendly way and ask me if I want to add it to my todo list?"}
                        ],
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
                    clarification_completion = client.chat.completions.create(
                        model="meta-llama/Llama-3.1-8B-Instruct",
                        messages=[
                            {"role": "system", "content": system_message},
                            {"role": "user", "content": message},
                            {"role": "assistant", "content": "I've identified a calendar event in your message."},
                            {"role": "user", "content": "Can you describe this event in a user-friendly way and ask me if I want to add it to my calendar?"}
                        ],
                        temperature=0.7
                    )
                    
                    bot_response = clarification_completion.choices[0].message.content
                else:
                    bot_response = response_message.content or "I've processed your request but couldn't generate a proper response."
            else:
                bot_response = response_message.content or "I couldn't understand your request. Please try rephrasing."
            
            return bot_response, generated_items if generated_items else None
            
        except Exception as e:
            print(f"Together API request error: {str(e)}")
            print(traceback.format_exc())
            # Provide a simple response if API call failed
            return f"I'm having trouble connecting to the AI service. Error: {str(e)}", None
    
    except Exception as e:
        print(f"Error processing chat message: {str(e)}")
        print(traceback.format_exc())
        return f"I'm sorry, I encountered an error: {str(e)}", None 