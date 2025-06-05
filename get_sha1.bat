@echo off
echo ======================================================
echo    Getting SHA-1 fingerprint for Google Sign-In
echo ======================================================
echo.
echo Step 1: Getting SHA-1 fingerprint...
cd android
echo.
gradlew.bat signingReport | findstr "SHA1"
echo.
echo ======================================================
echo    NEXT STEPS:
echo ======================================================
echo 1. Copy the SHA-1 fingerprint above
echo 2. Go to Firebase Console: https://console.firebase.google.com/project/diaryapp-389ed/settings/general
echo 3. Scroll to "Your apps" → Android app section
echo 4. Click "Add fingerprint" 
echo 5. Paste the SHA-1 fingerprint
echo 6. Click "Save"
echo 7. Download updated google-services.json
echo 8. Replace android/app/google-services.json with the new file
echo.
echo See AUTHENTICATION_SETUP_GUIDE.md for complete instructions.
echo.
pause
