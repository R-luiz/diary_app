# 🔐 Complete Authentication Setup Guide

## 🚨 Current Issues & Solutions

### Issue 1: Google Sign-In Fails ❌
**Problem**: Missing SHA-1 fingerprint in Firebase configuration
**Status**: Needs immediate fix

### Issue 2: GitHub Sign-In Not Working ❌  
**Problem**: GitHub OAuth not properly configured
**Status**: Needs setup

---

## 🔧 Fix Google Sign-In (Priority 1)

### Step 1: Get SHA-1 Fingerprint
```powershell
cd android
.\gradlew.bat signingReport
```

**Look for this in the output:**
```
Variant: debug
Store: C:\Users\[user]\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA-256: XX:XX:...
```

**Copy the SHA1 value!**

### Step 2: Add SHA-1 to Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/project/diaryapp-389ed/settings/general)
2. Scroll to **Your apps** → **Android app** section  
3. Click on your Android app (`com.example.diary_app`)
4. Scroll to **SHA certificate fingerprints**
5. Click **Add fingerprint** 
6. Paste your SHA-1 fingerprint
7. Click **Save**

### Step 3: Download Updated google-services.json
1. In Firebase Console → Project Settings → General
2. Scroll to **Your apps** → Android app
3. Click **Config** or the settings gear icon
4. Click **Download google-services.json**
5. Replace the file in `android/app/google-services.json`

### Step 4: Enable Google Authentication  
1. Go to [Firebase Authentication](https://console.firebase.google.com/project/diaryapp-389ed/authentication/providers)
2. Click **Sign-in method** tab
3. Click on **Google** provider
4. **Enable** the toggle
5. Set your email as project support email  
6. Click **Save**

---

## 🐙 Setup GitHub Sign-In (Priority 2)

### For Web Platforms:

#### Step 1: Create GitHub OAuth App
1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **New OAuth App**
3. Fill in:
   - **Application name**: `Diary App`
   - **Homepage URL**: `https://diaryapp-389ed.web.app`
   - **Authorization callback URL**: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler`
4. Click **Register application**
5. Copy the **Client ID** and **Client Secret**

#### Step 2: Configure Firebase GitHub Provider
1. Go to [Firebase Authentication](https://console.firebase.google.com/project/diaryapp-389ed/authentication/providers)
2. Click **Sign-in method** tab
3. Click on **GitHub** provider
4. **Enable** the toggle
5. Paste **Client ID** and **Client Secret** from GitHub
6. Click **Save**

### For Mobile Platforms:

#### Current Status: ⚠️ Setup Instructions Provided
- Mobile GitHub sign-in requires custom OAuth flow
- App will show helpful error message with setup instructions
- Users should use Google Sign-In on mobile for now

---

## 🧪 Testing Steps

### After Firebase Setup:
1. **Clean and rebuild**:
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Test Google Sign-In**:
   - Tap "Continue with Google" 
   - Should open Google account picker
   - Should successfully sign in

3. **Test GitHub Sign-In** (Web only):
   - Run `flutter run -d chrome`
   - Tap "Continue with GitHub"
   - Should redirect to GitHub authorization
   - Should successfully sign in

### Expected Behavior:
- **Mobile**: Google sign-in works, GitHub shows setup instructions
- **Web**: Both Google and GitHub sign-in work

---

## 🔍 Troubleshooting

### Google Sign-In Issues:
- **"API key not valid"** → Check SHA-1 fingerprint is added
- **"Network error"** → Check internet connection
- **"Sign-in failed"** → Verify google-services.json is updated

### GitHub Sign-In Issues:
- **"GitHub OAuth not configured"** → Follow GitHub setup steps above
- **Web only working** → This is expected, mobile needs additional setup

---

## 📋 Quick Checklist

### Google Sign-In Setup:
- [ ] Get SHA-1 fingerprint using gradlew
- [ ] Add SHA-1 to Firebase Console
- [ ] Download updated google-services.json
- [ ] Enable Google provider in Firebase Auth
- [ ] Test on Android device/emulator

### GitHub Sign-In Setup:
- [ ] Create GitHub OAuth App
- [ ] Configure Firebase GitHub provider
- [ ] Test on web browser
- [ ] Verify mobile shows setup instructions

### Final Testing:
- [ ] Clean and rebuild app
- [ ] Test Google sign-in on mobile
- [ ] Test GitHub sign-in on web
- [ ] Verify error messages are helpful

---

## 🆘 Need Help?

If you encounter issues:
1. Check the debug console output
2. Verify all steps were completed
3. Try on different devices/browsers
4. Check Firebase Console for error logs

**Most common issue**: Forgetting to add SHA-1 fingerprint to Firebase!
