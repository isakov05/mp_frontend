# final_project

README
Overview

This is a mobile application built with Flutter. It is a calorie counter and food tracking application that allows users to log meals, scan food using the camera, search food manually, track macronutrients, store history, and manage profile information.

The main feature of the project is the ability to take a picture of food and receive estimated calories and nutritional information using a backend AI model. Users can also manually search for foods and add them to their daily log.

The application supports authentication, dashboard analytics, meal history, food lookup, profile management, and daily nutrition goals.

Features:
- Authentication
- Email and password registration.
- Login form.
- Basic validation.
- Persistent login session.
- User can update name and password.

Dashboard:
- Shows calories consumed for the day.
- Circular ring indicating progress toward the daily calorie goal.
- Summary of protein, fat, and carb intake.
- List of foods logged today with nutrition details.
- Bottom navigation bar for switching screens.
- Food Scan (AI recognition)
- User takes a picture of a food item.
- Image is sent to backend AI service for recognition.
- Returns estimated calories, protein, fat, carbs.
- User can add the recognized food to their log.
- Manual Food Lookup
- Search for any food by name.
- Displays calories per 100g.
- Button to add food to the log.

History:
- Shows a full list of all previously logged foods.
- Each entry displays timestamp and nutrients.
- Items are sorted by date.

Profile:
- Shows user's email and display name.
- User can update name.
- User can change password.
- User can set daily nutrition goals (calories, protein, fat, carbs).
- Logout button.
- Supports light and dark mode.

Technology Used:
Flutter
Dart
Android and iOS support
Custom widgets for UI

Backend (not included here) for:
- authentication
- food recognition
- food database search
- storing logs
- fetching history

Folder Structure (simplified):
MP_FRONTEND/
    android/
    ios/
    lib/
        main.dart
        screens/
            login_screen.dart
            register_screen.dart
            dashboard_screen.dart
            history_screen.dart
            scan_screen.dart
            lookup_screen.dart
            profile_screen.dart
        widgets/
        models/
        services/
        utils/
    pubspec.yaml

How the App Works:
Login Page
User enters email and password. If an account does not exist, they can go to the register page.
Register Page
User fills name, email, password, confirm password. Creates an account.
Dashboard Page

Displays:
Daily calories consumed
Progress ring
Macronutrients
List of today's foods
Navigation bar to other screens

History Page
Shows all logged foods with full nutrition details and timestamps.

Scan Page
User takes a food picture. The backend identifies the food and returns calories and nutrients. User can save it into today’s log.

Lookup Page
User types a food name (example: "apple"). The system displays calories and nutrients for the food. User can add it to the daily log.

Profile Page
Allows user to:
Change name
Change password
Update daily nutrition goals
Logout
View email
Light and dark themes are supported automatically.

Setup Instructions
1. Install Flutter

Download from:
https://flutter.dev/docs/get-started/install

Check installation:

flutter doctor

2. Clone the repository
git clone https://github.com/isakov05/mp_frontend
cd MP_FRONTEND

3. Install packages
flutter pub get

4. Run on emulator or device

Start Android emulator or iOS simulator, then:

flutter run


Future Improvements
Better portion size estimation
Barcode scanner
Water intake tracking
More detailed analytics
Google Fit / Apple Health support
Offline mode

## Getting Started

Link to Backend

- [Backend](https://github.com/isakov05/project)

