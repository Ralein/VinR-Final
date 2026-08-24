# VinR — Emotional Wellness & Growth Platform

<div align="center">

> *"We don't just support you. We make you a WINNER."*

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.5-blueviolet?style=for-the-badge)](https://riverpod.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS-lightgrey?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)]()

</div>

---

## 🌟 Overview

**VinR** is a science-backed emotional wellness and personal growth mobile platform designed to turn mental health management into an empowering **21-day winning streak**.

This repository (`VinR-Final`) serves as the clean, Flutter-only foundation designed for a **100% offline-first, on-device AI architecture** (with zero server/FastAPI dependency).

---

## ✨ Features

- 🧠 **AI Buddy & Persona Chat**: Multi-persona conversational growth partner (*Hope, VinR Coach, Sage, Dr. Aris*).
- 🏆 **21-Day Winning Streak**: Structured habit formation, streak shield protection, milestones, and daily accountability.
- 🧘 **Immediate Relief & Grounding Rituals**: Science-backed techniques (4-7-8 tactical breathing, 5-4-3-2-1 sensory grounding, somatic movement).
- 📖 **Voice & Text Journaling**: Daily reflections, mood tracking, and sentiment insights.
- 🎨 **Midnight Gold Design System**: High-focus dark theme (`#07090F` Void background, Gold accents, Glassmorphism, glow avatars).
- 🔒 **Privacy First**: Ephemeral session memory and local encrypted storage.

---

## 🏗️ Architecture

```
lib/
├── main.dart                       # App entry point & Riverpod ProviderScope
├── core/
│   ├── navigation/
│   │   └── app_router.dart         # GoRouter navigation & route guards
│   ├── theme/
│   │   ├── vinr_colors.dart        # Midnight Gold design tokens
│   │   ├── vinr_theme.dart         # Dark ThemeData & Glassmorphic cards
│   │   └── vinr_typography.dart   # Typography hierarchy
│   ├── services/
│   │   ├── local_ai_service.dart   # On-device AI inference runtime abstraction
│   │   ├── storage_service.dart    # FlutterSecureStorage & SharedPreferences
│   │   ├── voice_recorder_service.dart # Audio recording
│   │   └── notification_service.dart   # Local notification triggers
│   └── repositories/               # Decoupled Data Access Layer
│       ├── auth_repository.dart
│       ├── chat_repository.dart
│       ├── streak_repository.dart
│       ├── journal_repository.dart
│       ├── checkin_repository.dart
│       ├── events_repository.dart
│       └── therapist_repository.dart
└── features/                       # 15 Modular Feature Areas
    ├── auth/                       # Authentication & profile onboarding
    ├── chat/                       # BuddyChatScreen (Personas, Glow avatars)
    ├── dashboard/                  # Home dashboard (Habits, quotes, quick actions)
    ├── journey/                    # 21-Day winning streak timeline
    ├── streak/                     # Streak analytics & milestones
    ├── journal/                    # Voice & text journaling
    ├── relief/                     # Grounding exercises (4-7-8, 5-4-3-2-1)
    ├── exercises/                  # Functional workouts & movement
    ├── glint/                      # Daily micro-reflections
    ├── therapist/                  # Therapist directory & triage
    ├── reels/                      # Wellness short videos
    ├── events/                     # Local & virtual wellness workshops
    ├── onboarding/                 # Multi-step goal & persona selection
    ├── profile/                    # User stats & badges
    └── settings/                   # Voice & theme settings
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.11+ / Dart 3.11+
- **Android Studio / Xcode** (for device deployment and emulators)

### Installation & Run

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Analyze code:**
   ```bash
   flutter analyze
   ```

3. **Run tests:**
   ```bash
   flutter test
   ```

4. **Launch Application:**
   ```bash
   flutter run
   ```

5. **Build APK (Debug):**
   ```bash
   flutter build apk --debug
   ```

---

## 📄 License

Confidential & Proprietary — All rights reserved © VinR Team.
# VinR-Final
