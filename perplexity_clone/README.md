Perplexity Clone

A Perplexity-inspired AI search and chat application built with Flutter for the frontend and FastAPI for the backend.  
The backend is designed to execute search and LLM requests in parallel, resulting in faster and more responsive answers.


Overview
This project replicates the core experience of Perplexity-style AI search:
- Ask a question
- Fetch information from multiple sources
- Generate a concise AI-powered response
- Display sources alongside answers
The project is structured as a monorepo, containing both the Flutter application and the FastAPI backend.


Tech Stack

Frontend
- Flutter
- Dart

Backend
- Python
- FastAPI
- Uvicorn
- Async / parallel execution


Prerequisites (Windows)

Make sure the following are installed on your system:
- Flutter SDK
- Python 3.10 or higher
- Git
- Android Studio or VS Code
- Virtualenv (`pip install virtualenv`)

Verify installations:
```bash
flutter doctor
python --version
````


Running the Project (Windows)

Step 1: Run the Backend

Open PowerShell or Command Prompt or terminal in vscode:
```bash
cd server
venv\Scripts\activate
uvicorn main:app --reload
```

What to expect
* Backend runs at `http://127.0.0.1:8000`
* Terminal logs show parallel task execution when searching
* Requests complete significantly faster due to async processing


Step 2: Run the Frontend

Open a new terminal window:
```bash
flutter run
```

* Select a connected device (Chrome, emulator, or physical device)
* The Flutter app communicates with the local FastAPI backend


Environment Variables

Create a `.env` file inside the `server` directory:
```env
OPENAI_API_KEY=your_api_key_here
```


Future Enhancements

* Streaming AI responses
* Authentication
* Response caching
* UI/UX improvements



