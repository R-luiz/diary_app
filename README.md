# My Diary App

A Flutter diary application with Firebase authentication and cloud storage.

## Features

- 🔐 **Authentication**: Google and GitHub sign-in
- 📖 **Diary Entries**: Create, read, update, and delete diary entries
- ☁️ **Cloud Storage**: All entries stored in Firebase Firestore
- 🎨 **Beautiful UI**: Modern, intuitive interface
- 🔒 **Secure**: Protected by Firebase Authentication

## Setup Instructions

### 1. Prerequisites

- Flutter SDK installed
- Firebase project created
- Android Studio or VS Code with Flutter plugins

### 2. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Authentication with Google and GitHub providers
4. Enable Firestore Database
5. Add your app platforms (Android/iOS/Web)
6. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

### 3. Update Firebase Options

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
// Replace these with your actual Firebase config values
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── diary_entry.dart     # Diary entry data model
├── services/
│   ├── auth_service.dart    # Authentication service
│   └── diary_service.dart   # Diary CRUD operations
└── pages/
    ├── login_page.dart      # Authentication page
    ├── diary_home_page.dart # Main diary page
    └── diary_entry_page.dart # Entry creation/editing
```

## Authentication Providers

### Google Sign-In
- Configured in Firebase Console
- Requires SHA-1 fingerprint for Android

### GitHub Sign-In
- Uses Firebase GitHub provider
- Requires OAuth app configuration in GitHub

## Database Structure

### Firestore Collections

**diary_entries**
```
{
  id: string,
  title: string,
  content: string,
  createdAt: timestamp,
  updatedAt: timestamp,
  userId: string
}
```

## Security Rules

Add these Firestore security rules to ensure users can only access their own entries:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /diary_entries/{document} {
      allow read, write, delete: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
