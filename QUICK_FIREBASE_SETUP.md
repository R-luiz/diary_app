# Quick Firebase Setup Guide - Fix Sign-In Issues

## Current Issue
Your app is failing to sign in because it's using placeholder Firebase configuration values. Here's how to fix it:

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `diary-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App to Firebase
1. In your Firebase project, click "Add app" → Android
2. **Important**: Use this exact package name: `com.example.diary_app`
   - This matches your current Android configuration
3. Enter app nickname: "Diary App"
4. Leave SHA-1 fingerprint empty for now (we'll add it later)
5. Click "Register app"
6. **Download the `google-services.json` file**
7. Place the file in: `android/app/google-services.json`

## Step 3: Get SHA-1 Fingerprint (Required for Google Sign-In)
Run this command in your project directory:
```bash
cd android
./gradlew signingReport
```
Or on Windows:
```cmd
cd android
gradlew.bat signingReport
```

Look for the **debug** keystore SHA-1 fingerprint and copy it.

## Step 4: Add SHA-1 to Firebase
1. In Firebase Console → Project Settings → Your Apps
2. Click on your Android app
3. Scroll down to "SHA certificate fingerprints"
4. Click "Add fingerprint"
5. Paste the SHA-1 fingerprint
6. Click "Save"

## Step 5: Enable Authentication Methods
1. In Firebase Console → Authentication → Sign-in method
2. Enable "Google" sign-in provider
3. Set project support email
4. Click "Save"

## Step 6: Create Firestore Database
1. In Firebase Console → Firestore Database
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose a location (preferably close to your users)
5. Click "Done"

## Step 7: Update Firebase Configuration
1. In Firebase Console → Project Settings → General
2. Scroll down to "Your apps" → Web app section
3. If no web app exists, click "Add app" → Web
4. Copy the Firebase config object

Replace the placeholder values in `lib/firebase_options.dart` with your real values:
- `projectId`: Your Firebase project ID
- `apiKey`: Your API keys for each platform
- `appId`: Your app IDs for each platform
- `messagingSenderId`: Your sender ID

## Step 8: Update Package Name (if needed)
If you want to use a different package name:
1. Update `android/app/build.gradle.kts` → `applicationId`
2. Update `android/app/src/main/AndroidManifest.xml` → `package`
3. Create new Android app in Firebase with the new package name

## Testing
After completing these steps:
1. Restart your app completely
2. Try the Google Sign-In button
3. Check the debug console for any remaining errors

## Common Issues & Solutions

### "API key not valid" error
- Make sure you've added the SHA-1 fingerprint to Firebase
- Verify the package name matches exactly

### "Network error" 
- Check internet connection
- Verify Firebase project is active

### "Sign-in failed" without specific error
- Clear app data and try again
- Check Firebase Authentication is enabled
- Verify google-services.json is in the correct location

## Need Help?
If you're still having issues after following these steps, please share:
1. The exact error message from the debug console
2. Your Firebase project ID
3. Whether you've completed all the steps above
