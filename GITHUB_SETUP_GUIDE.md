# GitHub Authentication Setup Guide

This guide will help you configure GitHub authentication for your Flutter diary app with Firebase.

## 🚨 IMPORTANT: If you're still getting the redirect_uri error

The most common cause is that you need to **create a completely new GitHub OAuth App** or **carefully update the existing one**. Follow these exact steps:

## Step 1: Create NEW GitHub OAuth App (Recommended)

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **"New OAuth App"** (don't try to edit an existing one first)
3. Fill in these EXACT details:

   ```
   Application name: Diary App Firebase
   Homepage URL: https://diaryapp-389ed.firebaseapp.com
   Application description: Personal diary app with Firebase authentication
   Authorization callback URL: https://diaryapp-389ed.firebaseapp.com/__/auth/handler
   ```

   ⚠️ **CRITICAL**: The redirect URI must be EXACTLY:
   ```
   https://diaryapp-389ed.firebaseapp.com/__/auth/handler
   ```
   
   **NO TRAILING SLASH, NO EXTRA CHARACTERS**

4. Click **"Register application"**

## Step 2: Get Client Credentials

After creating the OAuth app:

1. Copy the **Client ID** 
2. Click **"Generate a new client secret"**
3. Copy the **Client Secret** immediately (you can only see this once!)

## Step 3: Configure Firebase Console

1. Go to [Firebase Console Authentication](https://console.firebase.google.com/project/diaryapp-389ed/authentication/providers)
2. Click on **Authentication** → **Sign-in method**
3. Find **GitHub** in the providers list
4. If it's not enabled, click **Enable**
5. Enter the **Client ID** from step 2
6. Enter the **Client Secret** from step 2
7. Click **Save**

## Step 4: Verify Authorized Domains

1. In Firebase Console, go to **Authentication** → **Settings** → **Authorized domains**
2. Make sure these domains are listed:
   - `localhost` (for development)
   - `diaryapp-389ed.firebaseapp.com` (for production)

## Step 5: Test the Setup

1. Clear your browser cache and cookies
2. Run your Flutter app in debug mode:
   ```bash
   flutter run -d chrome --web-port 3000
   ```
3. Click the "Debug Configuration" button (only visible in debug mode)
4. Check the configuration status
5. Try the GitHub authentication

## 🔧 Troubleshooting

### Still getting "redirect_uri not associated" error?

1. **Double-check the redirect URI** in your GitHub OAuth App:
   - It must be exactly: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler`
   - No extra spaces, no trailing slash
   - Case-sensitive

2. **Create a completely new OAuth App** instead of editing an existing one

3. **Wait 5-10 minutes** after making changes (sometimes there's a delay)

4. **Clear browser cache** completely

5. **Check if you have multiple OAuth Apps** - make sure you're using the right Client ID

### Common Mistakes:

❌ **Wrong**: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler/`  
✅ **Correct**: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler`

❌ **Wrong**: `https://diaryapp-389ed.firebaseapp.com/auth/handler`  
✅ **Correct**: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler`

❌ **Wrong**: `http://diaryapp-389ed.firebaseapp.com/__/auth/handler`  
✅ **Correct**: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler`

### Debug Information:

- **Firebase Project ID**: `diaryapp-389ed`
- **Firebase Auth Domain**: `diaryapp-389ed.firebaseapp.com`
- **Required GitHub OAuth Redirect URI**: `https://diaryapp-389ed.firebaseapp.com/__/auth/handler`

## Alternative: Check Existing OAuth App

If you want to update an existing OAuth App instead:

1. Go to your [GitHub OAuth Apps](https://github.com/settings/developers)
2. Click on your existing app
3. Update the **Authorization callback URL** to exactly:
   ```
   https://diaryapp-389ed.firebaseapp.com/__/auth/handler
   ```
4. Click **"Update application"**
5. Wait 5-10 minutes for changes to propagate

## Testing Checklist

- [ ] New GitHub OAuth App created with correct redirect URI
- [ ] Client ID copied to Firebase Console  
- [ ] Client Secret copied to Firebase Console
- [ ] GitHub provider enabled in Firebase Console
- [ ] Authorized domains configured in Firebase
- [ ] Browser cache cleared
- [ ] App tested with debug configuration tool
- [ ] GitHub authorization redirects correctly
- [ ] User successfully signed in

Once all steps are complete and you've waited a few minutes, GitHub authentication should work perfectly!