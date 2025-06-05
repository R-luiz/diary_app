# My Diary App

A Flutter diary application with Firebase authentication and cloud storage.

## Features

- 🔐 **Authentication**: Google and GitHub sign-in
- 📖 **Diary Entries**: Create, read, update, and delete diary entries
- ☁️ **Cloud Storage**: All entries stored in Firebase Firestore
- 🎨 **Beautiful UI**: Modern, intuitive interface
- 🔒 **Secure**: Protected by Firebase Authentication

## Quick Start

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Authentication Status

- ✅ **Google Sign-In**: Fully configured and working
- ✅ **GitHub Sign-In**: Fully configured and working (both web and mobile)
- 🔒 **Secure Storage**: User credentials and profile data securely stored

## Firebase Configuration

The app is configured with Firebase project `diaryapp-389ed`:
- Authentication enabled (Google & GitHub providers)
- Firestore database enabled
- Configuration files properly set up
- Security rules implemented for user data isolation

## Technical Details

- **Framework**: Flutter
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **State Management**: StreamBuilder with Firebase Auth streams
- **Security**: User-based data isolation

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
