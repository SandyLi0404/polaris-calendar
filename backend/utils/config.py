import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

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
    
    # OpenAI (for chatbot)
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    
    # Reminders
    DEFAULT_REMINDER_TIME: int = 15  # minutes
    
    # Executive summary
    DEFAULT_SUMMARY_TIME: str = "07:00"  # 7 AM
    
    class Config:
        env_file = ".env"

# Create settings instance
settings = Settings() 