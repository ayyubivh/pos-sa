# POS App Configuration Guide

## Configuration Steps

Follow these steps to configure your POS application:

### 1. Change Package Name
**File:** `android/app/build.gradle.kts`

Search for `com.yourcompany.yourapp` and replace it with your package name (e.g., `com.ashalpos.mobilepos`)

You need to change it in TWO places:
- Line 9: `namespace = "com.yourcompany.yourapp"`
- Line 24: `applicationId = "com.yourcompany.yourapp"`

### 2. Change App Name
**File:** `android/app/src/main/AndroidManifest.xml`

Search for `YOUR_APP_NAME` and replace it with your app name (e.g., "Ashal POS")
- Line 3: `android:label="YOUR_APP_NAME"`

### 3. Change Logo
**Location:** `assets/logo/`

Replace the file `Blue Modern Up Arrow Illustration Financial Business Logo (1).png` with your own logo image.
Keep the same filename or update references in your code if you rename it.

### 4. Configure Base URL
**File:** `lib/api_end_points.dart`

Search for `YOUR_BASE_URL` and replace it with your server URL
- Line 2: `static String baseUrl = 'YOUR_BASE_URL';`
- Example: `static String baseUrl = 'https://yourserver.com';`

### 5. Configure Client Credentials
**File:** `lib/config.dart`

Get your Client ID and Client Secret from your API module connector dashboard, then:
- Line 9: Replace `YOUR_CLIENT_ID` with your client ID (e.g., '11')
- Line 10: Replace `YOUR_CLIENT_SECRET` with your client secret

Example:
```dart
String clientId = '11',
    clientSecret = 'okqASrLaobgrKphvxGwi0CG0Ty0YVTJUc9gn2w3L',
```

## Running the App

After making all the changes above:

1. **Clean the project:**
   ```bash
   flutter clean
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Quick Search & Replace

Use these search terms to find what needs to be changed:
- `YOUR_PACKAGE_NAME` or `com.yourcompany.yourapp` → Your package name
- `YOUR_APP_NAME` → Your app name
- `YOUR_BASE_URL` → Your server URL
- `YOUR_CLIENT_ID` → Your client ID
- `YOUR_CLIENT_SECRET` → Your client secret

## Notes

- Make sure you have Android Studio installed if you want to open the project there
- Ensure you have Flutter SDK installed and configured
- For logo changes, you may also need to update app icons in `android/app/src/main/res/mipmap-*` folders
