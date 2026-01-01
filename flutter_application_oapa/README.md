# Online Pet Adopting Mobile Application

A Flutter mobile application that connects people who want to adopt pets with shelters or individual pet owners.

## Features

### User Roles
- **Visitor**: Can browse pets without logging in
- **Registered User (Adopter)**: Can apply for adoption and track applications
- **Shelter/Owner**: Can create and manage pet listings, review applications
- **Admin**: Manages users, listings, and system moderation

### Core Functionality
- User registration and login
- Pet listing with search and filters (species, age, city, size)
- Pet detail view (photos, description, health status)
- Adoption application process
- Application status tracking
- Shelter pet management
- Shelter application approval/rejection
- Admin moderation
- In-app notifications

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user.dart
│   ├── pet.dart
│   ├── adoption_request.dart
│   └── notification.dart
├── services/            # Business logic and data access
│   ├── auth_service.dart
│   ├── pet_service.dart
│   ├── adoption_service.dart
│   └── notification_service.dart
├── providers/           # State management (Provider pattern)
│   └── auth_provider.dart
├── screens/             # UI Screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home_screen.dart
│   ├── pet_detail_screen.dart
│   ├── adoption_form_screen.dart
│   ├── my_applications_screen.dart
│   ├── profile_screen.dart
│   ├── notifications_screen.dart
│   ├── shelter/
│   │   ├── shelter_dashboard_screen.dart
│   │   ├── create_pet_screen.dart
│   │   └── application_review_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart
├── utils/               # Utilities
│   ├── constants.dart
│   └── theme.dart
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

```bash
flutter run
```

## Demo Accounts

The app includes demo accounts for testing:

**Admin:**
- Email: `admin@petapp.com`
- Password: `admin123`

**Shelter:**
- Email: `shelter@petapp.com`
- Password: `shelter123`

**Adopter:**
- You can register a new account as an adopter

## Architecture

The application follows a layered architecture:

- **Presentation Layer**: Flutter UI screens and widgets
- **Business Logic Layer**: Services (AuthService, PetService, etc.)
- **Data Access Layer**: In-memory storage (can be replaced with API calls)
- **State Management**: Provider pattern

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **HTTP Client**: http (for future API integration)

## Development Notes

- The app currently uses in-memory data storage for demonstration purposes
- In a production environment, replace service implementations with actual API calls
- All passwords are stored in plain text (demo only - use secure hashing in production)
- Image handling uses placeholder icons (implement image upload/storage in production)

## Future Enhancements

- Backend API integration
- Image upload functionality
- Real-time notifications
- Advanced search filters
- Pet matching algorithm
- User reviews and ratings

## License

This project is part of a Software Engineering course project following Kanban methodology.
