# Quiz App (Flutter Frontend)

This repository contains the Flutter client for a quiz app that uses:

- Firebase Firestore for quiz data and attempt history
- A deployed backend API for AI hints and AI performance analysis

## Repository Scope

This repo includes only frontend/mobile code.

- App UI and quiz flow
- Firestore integration
- API calls to backend service

Backend server code is not part of this repository.

## Main Flow

1. User enters name on Home screen.
2. App fetches questions from Firestore collection `questions`.
3. User answers quiz questions one by one.
4. On first wrong answer, app calls backend `POST /hint`.
5. On second wrong answer, app shows correct answer and continues.
6. At completion, app saves attempt in Firestore `quiz_attempts`.
7. App requests AI report from backend `POST /analyze`.
8. Result screen shows score chart, analysis button, and recent attempts.

## Project Structure

```text
lib/
  main.dart
  models/
  screens/
  services/
  widgets/
```

Key files:

- `lib/main.dart`: Firebase initialization and app theme
- `lib/services/firebase_service.dart`: Firestore reads/writes
- `lib/services/ai_api_service.dart`: Backend API calls (`/hint`, `/analyze`)
- `lib/screens/quiz_screen.dart`: Core quiz logic
- `lib/screens/result_screen.dart`: Score, history, and analysis entry

## Setup

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure Firebase values

Create `secrets.json` from `secrets.json.example` and fill these keys:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`

### 3) Prepare Firestore

Create these collections:

- `questions`
- `quiz_attempts`

### 4) Run the app

```bash
flutter run --dart-define-from-file=secrets.json
```

## Firestore Document Format

### `questions`

```json
{
  "question": "What is the capital of France?",
  "options": ["Paris", "Rome", "Berlin", "Madrid"],
  "answer": "Paris",
  "category": "Geography",
  "difficulty": "Easy"
}
```

### `quiz_attempts`

```json
{
  "name": "Nobita",
  "score": 7,
  "total": 10,
  "completedAt": "serverTimestamp()"
}
```

## Backend Integration

Current deployed API base URL:

- https://quiz-app-backend-fbn6.onrender.com

Configured in:

- `lib/services/ai_api_service.dart`

Endpoints used by app:

- `POST /hint`
- `POST /analyze`

## Useful Commands

```bash
flutter analyze
flutter test
```
