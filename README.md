# BookSwap - Flutter Firebase Textbook Exchange App

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart)

A modern Flutter application that enables students to exchange textbooks seamlessly using Firebase backend services. BookSwap demonstrates complete mobile development with authentication, real-time data synchronization, and complex state management.

## Demo & Documentation

- **Demo Video**: [Watch the Full Demo](https://youtu.be/GXXs-DYTPsg) 
- **Project Report**: [Download PDF Documentation](https://docs.google.com/document/d/1TG9l5oxw7dmydUepbXQjp0UeVh-EYwH86tyo5dMojvU/edit?usp=sharing)

##  Features

### Authentication & Security
- **Email/Password Authentication** with Firebase Auth
- **Email Verification** flow with proper UI routing
- **Secure Routing** - blocks unverified users from app features
- **Automatic Session Management** with Riverpod state

###  Book Management (CRUD Operations)
- **Create Listings** - Add textbooks with images and details
- **Real-time Reading** - Live updates across all devices
- **Update Listings** - Modify book conditions and swap preferences
- **Delete Books** - Swipe-to-delete with confirmation

###  Swap System
- **Make Offers** - Propose book exchanges to other users
- **Manage Offers** - Accept/reject incoming swap requests
- **Dual Perspectives** - Separate views for sent vs received offers
- **Real-time Status Updates** - Instant notification of offer changes

###  Navigation & State
- **Bottom Navigation** - Four main tabs: Browse, My Listings, Chats, Settings
- **Riverpod State Management** - Clean, testable architecture
- **Persistent State** - Maintains data across navigation
- **Optimized Queries** - Efficient Firestore data fetching

##  Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter 3.19 | Cross-platform UI framework |
| **Backend** | Firebase | BaaS (Backend as a Service) |
| **Authentication** | Firebase Auth | User management & security |
| **Database** | Cloud Firestore | Real-time NoSQL database |
| **Storage** | Firebase Storage | Image uploads & management |
| **State Management** | Riverpod | Predictable state container |
| **Language** | Dart 3.0 | Type-safe, compiled language |

##  Screenshots

| Authentication | My Listings | Browse Books | Swap Offers |
|----------------|-------------|--------------|-------------|
| ![Auth](https://1drv.ms/i/c/47659f4dae4e3118/EXVoRMNZ5TBDthjvVXgPwowBrKNkO2r5qz1gzHTS6TGtlA?e=n2X1ko) | ![Listings](https://1drv.ms/i/c/47659f4dae4e3118/EdPkzkQ6rd1DpbiEWCgwEBMBoRuNMqQAPToC60FD3Ac-1A?e=Te9YDC) | ![Browse](https://1drv.ms/i/c/47659f4dae4e3118/EWczG9rA6kFFtFYVv0NVYcMB5ckT9biP5HCpVsrqWlPhIw?e=eCswAU) | ![Offers](https://1drv.ms/i/c/47659f4dae4e3118/ERVELFprOstFmEnP7_29ZGkBb03aZgWI1gwwdlSiCP8ImQ?e=DiQQhg) |


## Architecture
[!diagram](https://1drv.ms/i/c/47659f4dae4e3118/EZ0JB0uT5-dNg2C0NewvvTYBAUmzu__5KYF-T51WJAgjmA?e=ftfuBu)


##  Getting Started

### Prerequisites
- Flutter SDK 3.19.0 or higher
- Dart 3.0 or higher
- Firebase project with enabled services
- Android Studio/VSCode with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Muen1/bookswap-flutter.git
   cd bookswap-flutter

2. **Firebase setup**
Create Firebase Project
 Go to Firebase Console
 Create new project: bookswap-flutter
 Enable Authentication with Email/Password
 Create Firestore Database in test mode
 Create Storage Bucket
Configure  Firebase for Flutter

3. **Environment configuration**
    ```dart
    class Config {
      static const String firebaseProjectId = 'your-project-id';
      static const bool useEmulator = true; // Set to false for production
    }

4. **Install Dependencies**
   ```bash
   flutter pub get

5. **Run Dart Analysis**
   ```bash
   flutter analyze
   dart format .
   dart analyze --fatal-infos

6. **Firebase Emulator Setup**

