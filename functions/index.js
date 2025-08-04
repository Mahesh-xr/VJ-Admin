const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function that triggers when a new notification is created
 * Sends push notifications to admin devices for technician actions
 */
exports.sendAdminNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    try {
      const notificationData = snap.data();
      const notificationId = context.params.notificationId;
      
      console.log(`📱 Processing notification: ${notificationId}`);
      
      // Check if notification has data field (new structure)
      let data;
      if (notificationData.data) {
        data = notificationData.data;
      } else {
        data = notificationData; // Old structure
      }
      
      // Only process relevant notification types
      const relevantTypes = ['service_accepted', 'service_rejected', 'service_completed'];
      if (!relevantTypes.includes(data.type)) {
        console.log(`⏭️ Skipping notification type: ${data.type}`);
        return null;
      }
      
      console.log(`✅ Processing ${data.type} notification for SR: ${data.srId}`);
      
      // Get all admin FCM tokens
      const adminSnapshot = await admin.firestore()
        .collection('admins')
        .get();
      
      const allTokens = [];
      
      adminSnapshot.forEach(doc => {
        const adminData = doc.data();
        if (adminData.fcmTokens && Array.isArray(adminData.fcmTokens)) {
          allTokens.push(...adminData.fcmTokens);
        } else if (adminData.fcmToken) {
          // Handle single token format
          allTokens.push(adminData.fcmToken);
        }
      });
      
      if (allTokens.length === 0) {
        console.log('⚠️ No admin FCM tokens found');
        return null;
      }
      
      console.log(`📱 Found ${allTokens.length} admin FCM tokens`);
      
      // Prepare notification payload
      const payload = {
        notification: {
          title: data.title || 'Service Request Update',
          body: data.message || 'A service request has been updated',
          sound: 'default',
        },
        data: {
          notificationId: notificationId,
          srId: data.srId || '',
          type: data.type,
          technicianName: data.technicianName || '',
          customerName: data.customerName || '',
          equipmentModel: data.equipmentModel || '',
          location: data.location || '',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'service_requests',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };
      
      // Send push notification to all admin devices
      const response = await admin.messaging().sendToDevice(allTokens, payload);
      
      console.log(`📱 Push notification sent to ${allTokens.length} devices`);
      console.log(`✅ Success: ${response.successCount}, ❌ Failed: ${response.failureCount}`);
      
      // Log any failures
      if (response.failureCount > 0) {
        response.results.forEach((result, index) => {
          if (!result.success) {
            console.error(`❌ Failed to send to token ${index}: ${result.error}`);
          }
        });
      }
      
      // Update notification document to mark push notification as sent
      await snap.ref.update({
        'data.pushNotificationSent': true,
        'data.pushNotificationSentAt': admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return { success: true, sentTo: allTokens.length };
      
    } catch (error) {
      console.error('❌ Error sending push notification:', error);
      return { success: false, error: error.message };
    }
  });

/**
 * Clean up invalid FCM tokens
 */
exports.cleanupInvalidTokens = functions.https.onRequest(async (req, res) => {
  try {
    const adminSnapshot = await admin.firestore()
      .collection('admins')
      .get();
    
    let cleanedCount = 0;
    
    for (const doc of adminSnapshot.docs) {
      const adminData = doc.data();
      const tokens = adminData.fcmTokens || [];
      const validTokens = [];
      
      // Check each token
      for (const token of tokens) {
        try {
          // Try to send a test message to validate token
          await admin.messaging().send({
            token: token,
            data: { test: 'validation' },
          }, true); // dryRun = true
          validTokens.push(token);
        } catch (error) {
          console.log(`❌ Invalid token removed: ${token.substring(0, 20)}...`);
        }
      }
      
      // Update admin document with valid tokens only
      if (validTokens.length !== tokens.length) {
        await doc.ref.update({
          fcmTokens: validTokens,
          lastTokenCleanup: admin.firestore.FieldValue.serverTimestamp(),
        });
        cleanedCount += (tokens.length - validTokens.length);
      }
    }
    
    res.json({ 
      success: true, 
      cleanedTokens: cleanedCount,
      message: `Cleaned up ${cleanedCount} invalid tokens`
    });
    
  } catch (error) {
    console.error('❌ Error cleaning up tokens:', error);
    res.status(500).json({ success: false, error: error.message });
  }
}); 