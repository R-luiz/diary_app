# 🔥 Firebase Setup Instructions for Diary App

## ⚠️ IMPORTANT: You must complete these steps before the app will work!

The authentication is currently failing because Firebase is not properly configured. Follow these steps:

## 📋 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `diary-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Wait for project creation

## 🔧 Step 2: Configure Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Google** provider:
   - Click on Google
   - Enable it
   - Add your email as test user (optional)
   - Click Save
3. Enable **GitHub** provider (optional for web):
   - Click on GitHub
   - Enable it
   - You'll need to create GitHub OAuth app (see below)

## 📱 Step 3: Add Android App

1. In Firebase Console, click **Add app** → **Android**
2. Enter package name: `com.example.diary_app`
3. Enter app nickname: `Diary App`
4. Download `google-services.json`
5. **IMPORTANT**: Place the file in `android/app/google-services.json`

## 🍎 Step 4: Add iOS App (if needed)

1. In Firebase Console, click **Add app** → **iOS**
2. Enter bundle ID: `com.example.diaryApp`
3. Enter app nickname: `Diary App`
4. Download `GoogleService-Info.plist`
5. **IMPORTANT**: Place the file in `ios/Runner/GoogleService-Info.plist`

## 🌐 Step 5: Add Web App (for GitHub auth)

1. In Firebase Console, click **Add app** → **Web**
2. Enter app nickname: `Diary App Web`
3. Copy the Firebase configuration
4. **IMPORTANT**: Update `lib/firebase_options.dart` with real values

## 🔑 Step 6: Get SHA-1 Fingerprint (Android)

For Google Sign-In on Android, you need SHA-1 fingerprint:

```bash
cd android
./gradlew signingReport
```

Or use keytool:
```bash
keytool -list -v -keystore %USERPROFILE%\\.android\\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

1. Copy the SHA-1 fingerprint
2. In Firebase Console → Project Settings → Your apps → Android app
3. Click "Add fingerprint" and paste the SHA-1

## 📝 Step 7: Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyC...', // Your actual API key from Firebase
  appId: '1:123456789:android:...', // Your actual app ID
  messagingSenderId: '123456789', // Your actual sender ID
  projectId: 'your-project-id', // Your actual project ID
  storageBucket: 'your-project-id.appspot.com',
);
```

## 🗃️ Step 8: Setup Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for now)
4. Select location (choose nearest to you)
5. Click **Create**

## 🔒 Step 9: Configure GitHub OAuth (Optional)

For GitHub sign-in:

1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - Application name: `Diary App`
   - Homepage URL: `https://your-project-id.firebaseapp.com`
   - Authorization callback URL: `https://your-project-id.firebaseapp.com/__/auth/handler`
4. Copy Client ID and Client Secret
5. In Firebase Console → Authentication → Sign-in method → GitHub
6. Paste Client ID and Client Secret

## ✅ Step 10: Test the Setup

1. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Try Google Sign-In
3. Check debug console for any error messages

## 🚨 Common Issues and Solutions

### Issue: "Default FirebaseApp is not initialized"
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean && flutter pub get`

### Issue: "Google Sign-In failed"
- Check SHA-1 fingerprint is added to Firebase
- Verify `google-services.json` is correct
- Check internet connection

### Issue: "GitHub Sign-In not working on mobile"
- GitHub auth works best on web
- For mobile, consider implementing custom OAuth flow
- Use Google Sign-In for mobile testing

### Issue: "Network error"
- Check Firestore security rules
- Verify project ID matches in `firebase_options.dart`
- Check internet permissions in AndroidManifest.xml

## 📞 Need Help?

If you're still having issues:

1. Check the debug console output
2. Verify all configuration files are in correct locations
3. Make sure project IDs match across all files
4. Try testing on different devices/emulators

## ✨ Quick Test Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Check for any analysis issues
flutter analyze

# Run on specific device
flutter devices
flutter run -d <device-id>
```

Once you complete these steps, the authentication should work perfectly! 🎉
