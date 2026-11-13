# 🌊 Flood Alert

A community-driven flood and landslide alert app for Sri Lanka, built with **Flutter** and **Firebase**. Residents can report incidents on a live map, and everyone in the same district gets notified so they can stay safe.

> 🚧 **Status:** Under development.

## ✨ Features

### Available now
- 🔐 Email login and registration, with automatic sign-in on app restart
- 👤 Profile with district and up to 5 emergency contacts
- 📍 Report floods, landslides and blocked roads with severity and GPS location
- 📋 Live, real-time list of recent reports
- 🗺️ Live map with color-coded pins (🟡 low, 🟠 medium, 🔴 high) and a report detail screen
- 🔔 Push notifications to everyone in the same district when a new report is submitted
- 🌐 Sinhala / English language support
- 🌙 Dark mode

### Planned
- 📸 Photo upload for reports
- 🆘 SOS button, "I'm safe" button and emergency numbers
- ✅ Community verification of reports
- 🛠️ Admin controls (remove fake reports, send official alerts)
- 🏠 Safe places map (shelters, hospitals, schools)
- 🤝 Community help (requests and offers)
- 🔥 Heatmap of high-risk areas
- 📴 Offline support

## 📱 How It Works

- **Authentication:** Firebase Auth with email and password. An `AuthGate` listens to the auth state, so login, register and logout switch screens automatically. Users pick one of Sri Lanka's 25 districts (shown in Sinhala or English).
- **Reporting:** A user chooses the incident type and severity, writes a description (10 to 300 characters) and the GPS location is captured automatically. Clear messages are shown when GPS is off or permission is denied, with a shortcut to the settings.
- **Live updates:** Reports are streamed from Cloud Firestore, so new reports appear instantly on both the list and the map.
- **Map:** Built with OpenStreetMap and `flutter_map`, so no API key or billing account is needed. Tapping a pin opens the report details.
- **Notifications:** Each user is subscribed to a Firebase Cloud Messaging topic for their own district (for example `district_anuradhapura`), and the subscription follows the district if it changes in the profile. After a report is saved, the app calls a small serverless API ([flood-alert-api](https://github.com/NethmiMandira/flood-alert-api)) with the user's Firebase ID token. The API verifies the user and sends the alert to that district's topic. Alerts show as a system notification in the background and as a snackbar while the app is open.

## 🗄️ Data Model

**`users/{uid}`**

| Field | Type | Notes |
|---|---|---|
| `uid` | string | Firebase Auth user id |
| `name` | string | Full name |
| `email` | string | Read-only in the profile screen |
| `district` | string | English district name, also used for the notification topic |
| `role` | string | `"user"` or `"admin"` |
| `emergencyContacts` | array | List of `{ name, phone }` (max 5) |
| `fcmToken` | string | Device token for Firebase Cloud Messaging |
| `createdAt` | timestamp | Server timestamp |

**`reports/{reportId}`**

| Field | Type | Notes |
|---|---|---|
| `userId`, `userName` | string | Who reported it |
| `type` | string | `flood`, `landslide` or `roadBlocked` |
| `severity` | string | `yellow`, `orange` or `red` |
| `description` | string | What is happening |
| `location` | geopoint | GPS position of the incident |
| `district` | string | Reporter's district |
| `status` | string | `active` or `resolved` |
| `confirmedBy` | array | User ids who confirmed the report (used in a later release) |
| `notified` | boolean | Set by the API once the district alert has been sent |
| `createdAt` | timestamp | Server timestamp |

## 🛠️ Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Cloud Firestore, Cloud Messaging) |
| State management | Provider |
| Localization | `flutter_localizations`, ARB files (`si`, `en`) |
| Local storage | `shared_preferences` (language and theme) |
| Map and location | `flutter_map` (OpenStreetMap), `latlong2`, `geolocator` |
| Notifications | `firebase_messaging`, `http` |
| Notification server | Next.js API route on Vercel with the Firebase Admin SDK (separate repository) |

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/   # districts list
│   ├── theme/       # light and dark themes
│   └── utils/       # auth error messages, report labels and colors
├── l10n/            # app_en.arb, app_si.arb
├── models/          # user_model.dart, report_model.dart
├── services/        # auth, user, report, location, notification, notify
├── providers/       # settings_provider.dart (language, theme)
├── features/
│   ├── auth/        # login, register, auth gate
│   ├── home/        # home screen with list and map tabs
│   ├── map/         # map screen with severity pins
│   ├── profile/     # profile and emergency contacts
│   └── report/      # add report, report details, report card
└── widgets/         # shared widgets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- A Firebase project (Authentication with Email/Password and Cloud Firestore enabled)
- Firebase CLI and FlutterFire CLI
- A real Android phone for testing push notifications

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/NethmiMandira/flood-alert.git
cd flood-alert

# 2. Install dependencies
flutter pub get

# 3. Connect your own Firebase project
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android

# 4. Run the app
flutter run
```

> `lib/firebase_options.dart` and `google-services.json` are generated by `flutterfire configure` and are not committed to the repository.

### Push notifications

Sending alerts needs the companion API:

1. Deploy [flood-alert-api](https://github.com/NethmiMandira/flood-alert-api) (for example on Vercel) with your own Firebase service account in its environment variables.
2. Set the API address in `lib/services/notify_service.dart` (`_baseUrl`).

## 🙏 Credits

Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors.

## 👩‍💻 Author

**Nethmi Mandira**
[GitHub](https://github.com/NethmiMandira) · [LinkedIn](https://www.linkedin.com/in/nethmi-mandira)