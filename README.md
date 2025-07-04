# Aura Secure – Female Safety App 🚨

Aura Secure is a mobile application designed to enhance personal safety for women by integrating real-time emergency features. The app allows users to share live location, send panic alerts, record audio in danger situations, and more. All user data is securely stored and managed using Firebase.

## 📱 Features

- **Live Location Sharing**: Automatically shares user’s current location during an emergency.
- **Panic Mode**: Triggers emergency actions such as audio recording and location sharing.
- **Audio Recording**: Records surroundings when panic mode is activated and saves it securely.
- **SOS Button**: A quick-access button to alert predefined emergency contacts.
- **Firebase Integration**: Stores user data, device logs, alert history, and more in real-time.

## 🛠️ Technologies Used

| Technology      | Purpose                              |
|----------------|--------------------------------------|
| Flutter         | Frontend UI and mobile app framework |
| Firebase        | Backend database and authentication  |
| Firestore DB    | Realtime database for user data      |
| Firebase Storage| Audio recording storage              |
| Geolocation API | Live location tracking               |


## 🗂️ Project Folder Structure


- `Aura/`
  - `android/` :rocket: Android-specific project files
  - `assets/` :art: Static assets like images and fonts
    - `images/` :camera: Image assets
  - `ios/` :apple: iOS-specific project files
  - `lib/` :gear: Main Dart source code
    - `api/` :cloud: API-related logic
    - `screen/` :tv: UI screens
      - `AuthScreens/` :lock: Authentication screens (Login, Signup, etc.)
      - `others/` :page_facing_up: Additional screens (Dashboard, Profile, etc.)
    - `service/` :wrench: Service logic
      - `database.dart` :floppy_disk: Database handling
      - `LiveLocationViewer.dart` :globe_with_meridians: Live location viewing
      - `Location.dart` :location_dot: Location services
      - `Panic_mode.dart` :exclamation: Panic mode functionality
      - `RecordingPage.dart` :microphone: Audio recording page
    - `others/` :pencil: Miscellaneous utilities
      - `AuraSecureLogo.dart` :art: App logo design
      - `KYCFormWithID.dart` :id: KYC form with ID
      - `splashscreen.dart` :splash: Splash screen
    - `main.dart` :rocket: Entry point of the Flutter app
  - `linux/` :computer: Linux-specific files
  - `macos/` :apple: macOS-specific files
  - `test/` :test_tube: Test files
  - `web/` :globe_with_meridians: Web-specific files
  - `windows/` :windows: Windows-specific files
  - `.gitignore` :no_entry_sign: Git ignored files
  - `pubspec.yaml` :package: Project dependencies and configuration
  - `README.md` :book: Project documentation
  - `flutter-plugins-dependencies` :puzzle_piece: Flutter plugin dependencies


# Aura Secure – Female Safety App 🚨

Aura Secure is a mobile application designed to enhance personal safety for women by integrating real-time emergency features and IoT concepts. The app allows users to share live location, send panic alerts, record audio in danger situations, and more. All user data is securely stored and managed using Firebase.

## 📱 Features

- **Live Location Sharing**: Automatically shares user’s current location during an emergency.
- **Panic Mode**: Triggers emergency actions such as audio recording and location sharing.
- **Audio Recording**: When record mode is enabled, the app captures your surroundings, which you can share with your pre-selected contacts.
- **SOS Button**: A quick-access button to alert predefined emergency contacts.
- **Firebase Integration**: Stores user data, device logs, alert history, and more in real-time.

## 🛠️ Technologies Used

| Technology      | Purpose                              |
|----------------|--------------------------------------|
| Flutter         | Frontend UI and mobile app framework |
| Firebase        | Backend database and authentication  |
| Firestore DB    | Realtime database for user data      |
| Firebase Storage| Audio recording storage              |
| Geolocation API | Live location tracking               |

## 🗂️ Project Folder Structure

- `Aura/`
  - `android/` :rocket: Android-specific project files
  - `assets/` :art: Static assets like images and fonts
    - `images/` :camera: Image assets
  - `ios/` :apple: iOS-specific project files
  - `lib/` :gear: Main Dart source code
    - `api/` :cloud: API-related logic
    - `screen/` :tv: UI screens
      - `AuthScreens/` :lock: Authentication screens (Login, Signup, etc.)
      - `others/` :page_facing_up: Additional screens (Dashboard, Profile, etc.)
    - `service/` :wrench: Service logic
      - `database.dart` :floppy_disk: Database handling
      - `LiveLocationViewer.dart` :globe_with_meridians: Live location viewing
      - `Location.dart` :location_dot: Location services
      - `Panic_mode.dart` :exclamation: Panic mode functionality
      - `RecordingPage.dart` :microphone: Audio recording page
    - `others/` :pencil: Miscellaneous utilities
      - `AuraSecureLogo.dart` :art: App logo design
      - `KYCFormWithID.dart` :id: KYC form with ID
      - `splashscreen.dart` :splash: Splash screen
    - `main.dart` :rocket: Entry point of the Flutter app
  - `linux/` :computer: Linux-specific files
  - `macos/` :apple: macOS-specific files
  - `test/` :test_tube: Test files
  - `web/` :globe_with_meridians: Web-specific files
  - `windows/` :windows: Windows-specific files
  - `.gitignore` :no_entry_sign: Git ignored files
  - `pubspec.yaml` :package: Project dependencies and configuration
  - `README.md` :book: Project documentation
  - `flutter-plugins-dependencies` :puzzle_piece: Flutter plugin dependencies

## 🔧 Installation

1. Ensure Flutter is installed on your system. Follow [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).After installation, Set up your system properly .
2. Clone the repository: `git clone https://github.com/yourusername/AuraSecure.git`.
3. Navigate to the project folder: `cd AuraSecure`.
4. Install dependencies: `flutter pub get`.
5. Set up Firebase: Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console and place them in the respective folders.
6. Run the app: `flutter run`.

## 📸 Screenshots

![Panic Mode](https://github.com/codermeghagithub/Project_Female_safety/blob/40c0cd44f03fb8f5b97a31f8504ec336731bc7e0/dashbord_github.png)
![Location Sharing](https://github.com/codermeghagithub/Project_Female_safety/blob/22e935ffeaadf041633b99b62c73ec356f136f78/this_ismobileformatscreensort.png)


## 🧑‍💻 Authors

- **Your Name** - [GitHub Profile](https://github.com/codermeghagithub)


## 🔗 Links

- [Firebase Setup Guide](https://firebase.google.com/docs)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


