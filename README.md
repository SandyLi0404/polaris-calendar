# Polaris Calendar

A modern calendar and todo application with intelligent chatbot integration.

## Features

### Calendar
- Weekly and monthly views
- Manual event creation with ICS file generation
- Event tagging system
- ICS file import
- Todo deadline integration
- Smart event reminders
- Intelligent conflict resolution

### Todo
- Daily event overview
- Microsoft Todo-inspired interface
- Priority level management (high/low)
- Flexible sorting (alphabetical, deadline, importance)
- Deadline reminder system

### Smart Assistant
- Multi-modal input support (text, audio, image)
- Automated calendar and todo item creation
- User confirmation workflow
- Daily executive summary generation
- Interactive clarification system

## Tech Stack
- **Backend**: Python
- **Frontend**: Flutter/Dart
- **UI**: Dark mode, Notion Calendar-inspired interface

## Project Structure
```
polaris-calendar/
├── backend/             # Python backend
│   ├── api/             # API endpoints
│   ├── models/          # Data models
│   ├── services/        # Business logic
│   └── utils/           # Helper functions
├── frontend/            # Flutter application
│   ├── lib/
│   │   ├── models/      # Data models
│   │   ├── screens/     # UI screens
│   │   ├── widgets/     # Reusable components
│   │   └── services/    # API integration
│   └── assets/          # Images, fonts, etc.
└── docs/                # Documentation
```

## Setup Instructions

### Backend Setup
1. Ensure Python 3.8+ is installed
2. Create and activate a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```
   pip install -r backend/requirements.txt
   ```
4. Run the backend server:
   ```
   python backend/main.py
   ```

### Frontend Setup
1. Install Flutter (https://flutter.dev/docs/get-started/install)
2. Install dependencies:
   ```
   cd frontend
   flutter pub get
   ```
3. Run the application:
   ```
   flutter run
   ```

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 