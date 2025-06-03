# ✅ Firebase Setup Checklist

## Your Information
- **SHA-1 Fingerprint**: `29:4D:26:A2:53:E8:2A:97:91:39:C8:A8:ED:FE:FB:57:EB:A0:D5:53`
- **Package Name**: `com.example.diary_app`
- **App Location**: `android/app/google-services.json`

## Step-by-Step Checklist

### [ ] 1. Create Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/)
- Click "Create a project"
- Enter project name (e.g., "diary-app")
- Complete project creation

### [ ] 2. Add Android App
- In your Firebase project, click "Add app" → Android
- Package name: `com.example.diary_app`
- App nickname: "Diary App"
- SHA-1 fingerprint: `29:4D:26:A2:53:E8:2A:97:91:39:C8:A8:ED:FE:FB:57:EB:A0:D5:53`
- Click "Register app"

### [ ] 3. Download Configuration File
- Download `google-services.json`
- Place it in: `android/app/google-services.json`
- ⚠️ Make sure it's in the `app` folder, not the root `android` folder

### [ ] 4. Enable Google Authentication
- Firebase Console → Authentication → Sign-in method
- Click on "Google"
- Enable the toggle
- Set your email as project support email
- Click "Save"

### [ ] 5. Create Firestore Database
- Firebase Console → Firestore Database
- Click "Create database"
- Start in **test mode** (allows read/write during development)
- Choose a location close to your users
- Click "Done"

### [ ] 6. Update Firebase Configuration
- Firebase Console → Project Settings → General
- Scroll to "Your apps" → Android app
- Click "Config" or view configuration
- Copy the configuration values
- Replace placeholder values in `lib/firebase_options.dart`

Required fields to update:
- `projectId`: your-firebase-project-id
- `apiKey`: your-android-api-key
- `appId`: your-android-app-id
- `messagingSenderId`: your-sender-id
- `storageBucket`: your-project-id.appspot.com

### [ ] 7. Test the Application
```bash
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

### "API key not valid" Error
- ✅ Verify SHA-1 fingerprint is added to Firebase
- ✅ Verify package name matches exactly
- ✅ Verify google-services.json is in correct location

### "Network Error" 
- ✅ Check internet connection
- ✅ Verify Firebase project is active
- ✅ Check if you're behind a firewall

### App Crashes on Startup
- ✅ Check debug console for Firebase initialization errors
- ✅ Verify all placeholder values are replaced in firebase_options.dart
- ✅ Try `flutter clean && flutter pub get`

### Google Sign-In Button Does Nothing
- ✅ Check if Google provider is enabled in Firebase Auth
- ✅ Verify SHA-1 fingerprint is correct
- ✅ Check debug console for authentication errors

## Quick Test Commands
```bash
# Clean and rebuild
flutter clean && flutter pub get

# Run with verbose logging
flutter run -v

# Check for issues
flutter doctor
```

## Need Help?
If you're still having issues:
1. Check the debug console output (VS Code Debug Console)
2. Verify each checkbox above is completed
3. Try running `flutter clean && flutter pub get && flutter run`
4. Share the exact error message you're seeing
