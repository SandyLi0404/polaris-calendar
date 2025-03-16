# Polaris Calendar Functional Specification and Tech Stack

## Functional Specification

### Calendar
- **Views:** Weekly and monthly views.
- **Event Management:**
  - Add events manually, generating ICS files stored in a database.
  - Import events from ICS formatted files.
  - Add metadata tags to events.
- **Reminders & Conflict Resolution:**
  - Display Todo deadlines.
  - Remind the user before an event.
  - Intelligently resolve scheduling conflicts.

### Todo
- **Display & Management:**
  - Display today’s events.
  - Mimic Microsoft Todo functionalities.
- **Features:**
  - Set priority levels (high/low).
  - Sort tasks alphabetically, by deadline, or by importance.
  - Remind the user before a deadline.

### ChatBot
- **Input Modalities:**
  - Accept image, audio, and text inputs.
- **Functionalities:**
  - Generate Todo and Calendar items directly after user confirmation.
  - Provide an executive summary every morning at a user-set time.
  - Ask clarifying questions when instructions are unclear.

---

## Tech Stack

### Backend

**Primary Language & Framework:**
- **Python:** The core language for backend logic.
- **Framework:** Use an asynchronous framework like **FastAPI** for high performance and responsiveness, especially for real-time updates and reminders.

**ICS File Handling:**
- **Library:** Utilize the [ics](https://pypi.org/project/ics/) Python package to generate and parse ICS files, supporting both manual event creation and imports.

**Task Scheduling & Reminders:**
- **Scheduler:** Implement **APScheduler** for lightweight scheduling, or use **Celery** with a message broker (e.g., Redis) for robust background task management.

**Business Logic:**
- Develop custom Python modules to manage calendar events, Todo tasks, conflict resolution, and metadata tagging.

### Frontend

**User Interface:**
- **Framework:** Build the frontend using modern JavaScript frameworks like **React.js** or **Vue.js**.
- **Calendar Display:** Integrate libraries such as [FullCalendar](https://fullcalendar.io/) for interactive weekly and monthly views.

**Todo & ChatBot UI:**
- Design intuitive interfaces for task management (similar to Microsoft Todo) and ChatBot interactions (supporting text, image, and audio inputs).

### Database & Storage

**Relational Database:**
- **PostgreSQL:** Recommended for scalable and robust relational data management (e.g., events, ICS files, metadata). Alternatively, **SQLite** can be used for simpler setups.

**File Storage:**
- Utilize local or cloud-based storage for persisting uploaded ICS files if necessary.

### ChatBot & Llama Integration

**ChatBot Core:**
- Build a ChatBot capable of processing image, audio, and text inputs to generate calendar and Todo items, with confirmation prompts before database insertion.

**Online Hosted Llama API Integration:**
- **Service Choice:** Leverage an online hosted Llama API, such as the one provided by [Hugging Face’s Inference API](https://huggingface.co/inference-api), rather than hosting Llama locally.
- **Steps to Obtain & Integrate:**
  1. **Sign Up:** Create a free account on [Hugging Face](https://huggingface.co/).
  2. **API Token:** Generate an API token from your account settings.
  3. **Model Selection:** Choose an available Llama-based model from Hugging Face’s model hub.
  4. **Integration:** Use Python’s `requests` library (or similar) to call the Hugging Face Inference API endpoints within your backend logic. This will process natural language inputs and generate responses for calendar and Todo functionalities.
  5. **Usage Considerations:** Monitor free tier usage limits and be prepared to upgrade if necessary.

**Additional Input Processing:**
- **Image Processing:** Use libraries like **Pillow** or **OpenCV**.
- **Audio Processing:** Employ **SpeechRecognition** or **PyAudio** to convert audio inputs into text.

### DevOps & Deployment

**Containerization:**
- **Docker:** Containerize the application to ensure consistency across different deployment environments.

**Version Control & CI/CD:**
- **Git:** Manage code using Git.
- **CI/CD:** Use platforms like GitHub Actions to automate testing and deployment pipelines.

**Hosting:**
- Deploy on cloud platforms such as **AWS**, **GCP**, **Azure**, or **DigitalOcean** based on your scalability and performance requirements.

**Logging & Monitoring:**
- Integrate Python’s logging framework and consider tools like **Sentry** for error tracking and performance monitoring.

---

This document presents a comprehensive overview of the Polaris Calendar project, detailing the functional specifications and a robust tech stack. The updated ChatBot integration now leverages an online hosted Llama API, ensuring efficient natural language processing without the overhead of local model hosting.
