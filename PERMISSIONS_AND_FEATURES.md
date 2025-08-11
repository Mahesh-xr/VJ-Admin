# Vayujal App - Permissions and Features Documentation

## App Overview
Vayujal is a service management app with admin capabilities for managing service requests, user profiles, device documentation, and multimedia content.

## Core Features

### 1. Service Request Management
- **Description**: Admin panel for managing service requests with filtering and search capabilities
- **Features**: 
  - View all service requests
  - Filter by status (All, Pending, In Progress, Delayed, Completed)
  - Search functionality
  - Edit and delete service requests
  - Assign technicians to requests
  - Track request status and acceptance

### 2. User Authentication & Profile Management
- **Description**: Firebase Auth integration with profile setup
- **Features**:
  - User login/logout
  - Profile image upload (camera/gallery)
  - Profile information management
  - Firebase Storage integration for profile images

### 3. Device Management
- **Description**: Add and manage devices with photo documentation
- **Features**:
  - Add new devices
  - Upload multiple photos per device
  - Camera and gallery access for device photos
  - Firebase Storage integration for device images

### 4. Video Player
- **Description**: Fullscreen video playback functionality
- **Features**:
  - Network video playback
  - Fullscreen mode
  - Custom controls
  - Error handling
  - Video player controls overlay

### 5. Push Notifications
- **Description**: Firebase Cloud Messaging integration
- **Features**:
  - Service request notifications
  - Technician assignment notifications
  - Background message handling
  - Foreground message display
  - Token management

### 6. Local Notifications
- **Description**: In-app notification system
- **Features**:
  - Custom notification channels
  - Sound and vibration
  - Badge management
  - Notification actions

## Required Permissions

### Android Permissions (android/app/src/main/AndroidManifest.xml)

#### Internet & Network
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```
- **Purpose**: Required for Firebase operations, video streaming, and network requests

#### Camera & Media
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```
- **Purpose**: Camera access for taking profile pictures and device photos

#### Storage
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
- **Purpose**: Access to photo gallery and saving images

#### Notifications
```xml
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```
- **Purpose**: Push notifications and local notifications

#### Audio
```xml
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```
- **Purpose**: Video player audio controls

#### Location (Optional)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
- **Purpose**: Location-based services for service requests

### iOS Permissions (ios/Runner/Info.plist)

#### Camera
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos for profile pictures and device documentation.</string>
```

#### Photo Library
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images for profile pictures and device documentation.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos to your photo library.</string>
```

#### Microphone
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video recording functionality.</string>
```

#### Location (Optional)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based services.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based services.</string>
```

#### Background Modes
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
    <string>background-fetch</string>
</array>
```

## Firebase Configuration

### Android
- `google-services.json` file in `android/app/`
- Firebase Messaging Service configured in AndroidManifest.xml
- Default notification icon and color configured

### iOS
- `GoogleService-Info.plist` file in `ios/Runner/`
- Firebase configuration in AppDelegate.swift
- Push notification handling configured

## Dependencies (pubspec.yaml)

### Core Dependencies
- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Database operations
- `firebase_storage`: File storage
- `firebase_messaging`: Push notifications

### Media Dependencies
- `image_picker`: Camera and gallery access
- `video_player`: Video playback
- `chewie`: Enhanced video player UI

### Notification Dependencies
- `flutter_local_notifications`: Local notifications

### Utility Dependencies
- `http`: Network requests
- `intl`: Internationalization
- `path`: File path handling
- `url_launcher`: URL opening
- `crypto`: Encryption utilities

## Security Considerations

### App Transport Security (iOS)
- Configured to allow Firebase domains
- Secure network communication

### Firebase Security
- Authentication required for sensitive operations
- Storage rules should be configured
- Firestore security rules should be implemented

## Testing Permissions

### Android Testing
1. Install app on Android device
2. Grant permissions when prompted
3. Test camera access
4. Test photo gallery access
5. Test push notifications
6. Test video playback

### iOS Testing
1. Install app on iOS device
2. Grant permissions when prompted
3. Test camera access
4. Test photo library access
5. Test push notifications
6. Test video playback

## Troubleshooting

### Common Issues
1. **Camera not working**: Check camera permissions in device settings
2. **Photos not uploading**: Check storage permissions and Firebase configuration
3. **Push notifications not working**: Check Firebase configuration and device settings
4. **Video not playing**: Check network permissions and video URL validity

### Debug Steps
1. Check device logs for permission errors
2. Verify Firebase configuration files
3. Test permissions individually
4. Check network connectivity
5. Verify Firebase project settings

## Build Configuration

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: Latest stable
- Compile SDK: Latest stable

### iOS
- Minimum iOS: 12.0
- Target iOS: Latest stable
- Swift version: 5.0

## Deployment Notes

### Android
- Ensure `google-services.json` is included in release builds
- Test on multiple Android versions
- Verify permissions work on all target devices

### iOS
- Ensure `GoogleService-Info.plist` is included in release builds
- Test on multiple iOS versions
- Verify App Store guidelines compliance 