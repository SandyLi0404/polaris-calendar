import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv
from typing import ClassVar

# Load environment variables from .env file
load_dotenv()

class Settings(BaseSettings):
    # Application settings
    APP_NAME: str = "Polaris Calendar"
    APP_VERSION: str = "1.0.0"
    
    # Authentication
    SECRET_KEY: str = os.getenv("SECRET_KEY", "change_this_in_production_with_secure_key")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./polaris_calendar.db")
    
    # Together AI (for Llama models)
    TOGETHER_API_KEY: str = ""
    
    # Reminders
    DEFAULT_REMINDER_TIME: int = 15  # minutes
    
    # Executive summary
    DEFAULT_SUMMARY_TIME: str = "07:00"  # 7 AM
    
    class Config:
        env_file = ".env"


# Create settings instance
settings = Settings()

# Load Together API key from file
try:
    # Get the current directory
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # Navigate to the backend directory (utils is inside backend)
    backend_dir = os.path.dirname(current_dir)
    # Path to the API key file
    api_key_path = os.path.join(backend_dir, "TOGETHER_API_KEY")
    
    print(f"Looking for API key at: {api_key_path}")
    print(f"File exists: {os.path.exists(api_key_path)}")
    
    if os.path.exists(api_key_path):
        with open(api_key_path, "r") as f:
            settings.TOGETHER_API_KEY = f.read().strip()
            print(f"API key loaded, length: {len(settings.TOGETHER_API_KEY)}")
    else:
        # Try reading from environment
        settings.TOGETHER_API_KEY = os.getenv("TOGETHER_API_KEY", "")
        print(f"Using env API key, length: {len(settings.TOGETHER_API_KEY)}")
except Exception as e:
    print(f"Error loading Together API key: {e}")
    # Try reading from environment
    settings.TOGETHER_API_KEY = os.getenv("TOGETHER_API_KEY", "") 