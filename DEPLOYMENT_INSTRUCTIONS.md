# Push Notification Deployment Instructions

## Overview
This implementation provides real-time push notifications to admin devices when technicians accept, reject, or complete service requests.

## Components Implemented

### 1. Flutter App (main.dart)
- ✅ FCM initialization and setup
- ✅ Foreground/background message handling
- ✅ Local notification display
- ✅ Function to save admin FCM token: `saveAdminFcmToken(adminId, fcmToken)`

### 2. Cloud Function (functions/index.js)
- ✅ `sendAdminNotification` function that triggers on new documents in notifications collection
- ✅ Sends push notifications to all admin devices when technician actions occur

### 3. Dependencies (pubspec.yaml)
- ✅ `firebase_messaging: ^15.2.6`
- ✅ `flutter_local_notifications: ^17.2.2`

## Deployment Steps

### Step 1: Deploy Cloud Functions

1. **Navigate to functions directory:**
   ```bash
   cd vayujal-main/functions
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Deploy functions:**
   ```bash
   firebase deploy --only functions
   ```

4. **Verify deployment:**
   ```bash
   firebase functions:list
   ```

### Step 2: Test the Flow

1. **Login to admin app** - FCM token will be automatically saved
2. **Have a technician accept/reject a service request** in their app
3. **Admin app writes notification document** to Firestore
4. **Cloud Function automatically sends push notification** to all admin devices
5. **Admin receives push notification banner**

## Flow Diagram

```
Technician App                    Firestore                    Admin App
     |                               |                            |
     | Accept/Reject SR              |                            |
     |------------------------------>|                            |
     |                               | Create notification doc    |
     |                               |--------------------------->|
     |                               |                            |
     |                               | Cloud Function triggers    |
     |                               |<---------------------------|
     |                               |                            |
     |                               | Send FCM push notification |
     |                               |--------------------------->|
     |                               |                            |
     |                               | Show notification banner   |
     |                               |                            |
```

## Testing

### Test Push Notifications

1. **Send test notification via Firebase Console:**
   - Go to Firebase Console > Cloud Messaging
   - Send test message to your app

2. **Test via Cloud Function:**
   - Create a test notification document in Firestore
   - Check Cloud Function logs for execution

### Monitor Logs

```bash
# View Cloud Function logs
firebase functions:log

# View specific function logs
firebase functions:log --only sendAdminNotification
```

## Troubleshooting

### Common Issues

1. **FCM token not saved:**
   - Check Firebase Auth is initialized
   - Verify user is logged in before saving token

2. **Push notifications not received:**
   - Check device notification permissions
   - Verify FCM token is valid
   - Check Cloud Function logs for errors

3. **Cloud Function not triggering:**
   - Verify function is deployed
   - Check Firestore rules allow function access
   - Verify notification document structure

### Debug Commands

```bash
# Check FCM tokens in Firestore
firebase firestore:get admins

# Test Cloud Function manually
firebase functions:shell
> sendAdminNotification({data: {type: 'service_accepted', srId: 'TEST_123'}})
```

## Security Considerations

1. **Firestore Rules:** Ensure only authenticated users can read/write notifications
2. **FCM Tokens:** Store tokens securely, clean up invalid tokens
3. **Function Permissions:** Cloud Function should have minimal required permissions

## Performance Optimization

1. **Token Cleanup:** Run `cleanupInvalidTokens` function periodically
2. **Batch Notifications:** Consider batching multiple notifications
3. **Rate Limiting:** Implement rate limiting for push notifications

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review Cloud Function execution logs
3. Verify FCM token validity
4. Test with Firebase Console test messages 