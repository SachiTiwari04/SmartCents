# Cloud Firestore API Setup Guide

## Problem
Your app is showing this error:
```
Cloud Firestore API has not been used in project smartcents-app-d13b4 before or it is disabled.
```

## Solution: Enable Cloud Firestore API

### Step 1: Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **smartcents-app-d13b4**

### Step 2: Enable Firestore API
1. Click on **Build** in the left sidebar
2. Select **Firestore Database**
3. Click **Create database** (if not already created)
4. Choose **Start in production mode** or **Start in test mode**
   - **Test mode**: For development (allows all reads/writes)
   - **Production mode**: For production (requires security rules)
5. Select your region (e.g., `us-central1`)
6. Click **Create**

### Step 3: Set Security Rules (CRITICAL!)
Once Firestore is created, go to **Rules** tab and update the security rules.

**⚠️ IMPORTANT**: Your app is currently showing "Missing or insufficient permissions" errors. This means the default rules are blocking access.

#### Quick Fix for Development:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **smartcents-app-d13b4** project
3. Click **Build** → **Firestore Database** → **Rules** tab
4. Replace ALL content with this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own user document and subcollections
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // All subcollections under user document
      match /{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

5. Click **Publish** button
6. Wait 30 seconds for rules to apply
7. Hot restart your Flutter app

#### For Production (More Secure):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Transactions subcollection
      match /transactions/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Challenges subcollection
      match /challenges/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Predictions subcollection
      match /predictions/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

### Step 4: Wait for API to Propagate
- After enabling, wait 1-2 minutes for the API to propagate
- The warnings in your logs should disappear

## What Changed in Code

The app now has:
- ✅ **Offline persistence enabled** - Data syncs when connection is restored
- ✅ **Better error handling** - Specific error messages for Firestore issues
- ✅ **Graceful degradation** - App continues working even if Firestore is unavailable
- ✅ **Helpful tips** - Debug logs suggest enabling Firestore API if permission denied

## Testing

1. Hot reload your app after enabling Firestore
2. Try creating a transaction or saving a prediction
3. Check the console logs - you should see:
   ```
   ✅ Transaction added successfully
   ✅ Prediction saved to Firestore
   ```

## Troubleshooting

### Still seeing "Missing or insufficient permissions" errors?
**This means your security rules are blocking access.**

1. Go to Firebase Console → **smartcents-app-d13b4** → **Firestore Database** → **Rules**
2. Copy the "Quick Fix for Development" rules from Step 3 above
3. Replace all existing rules with the new ones
4. Click **Publish**
5. Wait 30 seconds
6. Hot restart your Flutter app

### Still seeing "PERMISSION_DENIED" errors after updating rules?
- Clear app cache: Settings → Apps → SmartCents → Storage → Clear Cache
- Uninstall and reinstall the app
- Ensure you're logged in with a valid Firebase user
- Check that your user ID matches in the rules

### Offline mode is active?
- This is normal! The app will sync data when connection is restored
- Check your internet connection
- Verify Firestore API is enabled in Firebase Console

### How to verify rules are working?
1. Create a transaction or prediction in the app
2. Check Firebase Console → Firestore Database → Data tab
3. You should see your data under `users/{userId}/transactions` or `users/{userId}/predictions`

### Need help?
- Visit: https://firebase.google.com/docs/firestore/quickstart
- Check Firebase Console for API usage and errors
- Review Firestore security rules: https://firebase.google.com/docs/firestore/security/get-started
