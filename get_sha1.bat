@echo off
echo Getting SHA-1 fingerprint for Google Sign-In setup...
echo.
cd android
echo Running gradlew signingReport...
echo.
gradlew.bat signingReport | findstr "SHA1"
echo.
echo Copy the SHA-1 fingerprint above and add it to your Firebase project.
echo Go to Firebase Console → Project Settings → Your Apps → SHA certificate fingerprints
echo.
pause
