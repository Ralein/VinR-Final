# VinR Architecture Audit — AI & Offline Integration

**Date:** 2026-08-30  
**Status:** Completed  
**Author:** Principal Senior Engineering

---

## 1. Executive Summary

This document captures the current architecture of the VinR codebase prior to the Local AI / Offline-First subsystem integration. It maps all current service layers, repositories, Riverpod providers, navigation routes, UI screens, and external dependencies.

---

## 2. Existing Core Services & Repositories

| Component | Path | Current Role | AI Integration Plan |
|---|---|---|---|
| `LocalAIService` | `lib/core/services/local_ai_service.dart` | Hardcoded stub singleton generating static string responses | Refactor into implementation detail behind `LocalLlmRuntime` / `AiOrchestrator` |
| `StorageService` | `lib/core/services/storage_service.dart` | Key-value token and pref storage using `SharedPreferences` + `FlutterSecureStorage` | Integrate with `AiDatabase` for atomic local persistence |
| `VoiceRecorderService` | `lib/core/services/voice_recorder_service.dart` | Records WAV audio and attempts remote upload to `ApiService` | Overhaul to connect with local offline `SpeechToTextService` and `TextToSpeechService` |
| `ApiService` | `lib/core/services/api_service.dart` | Remote Dio HTTP client | Maintained for optional remote syncing; strictly barred from receiving private conversations / memories |
| `NotificationService` | `lib/core/services/notification_service.dart` | Schedules daily streak reminders and local notifications | Connect to deterministic streak nudges and cached AI reflections |
| `ChatRepository` | `lib/core/repositories/chat_repository.dart` | Dispatches chat messages to remote API with fallback to `LocalAIService` stub | Refactor to utilize `AiOrchestrator` and `ConversationStore` directly |
| `StreakRepository` | `lib/core/repositories/streak_repository.dart` | Manages 21-day winning streak data and day completions | Feeds deterministic streak state into `ContextBuilder` for personalized AI coaching |
| `JournalRepository` | `lib/core/repositories/journal_repository.dart` | Handles journal entries and reflections | Feeds context into `JournalAssist` AI task with prompt injection protections |
| `CheckinRepository` | `lib/core/repositories/checkin_repository.dart` | Daily check-in ratings and mood tracking | Supplies mood signals to AI context builder |

---

## 3. Presentation & Feature Mapping

### 3.1 Chat Subsystem (`lib/features/chat/`)
- **`BuddyChatScreen`**: Full-featured chat UI with persona switcher (VinR Coach, Zen Master, Stoic Guardian, Solar Spark), audio player for TTS playback, mic gesture recording, and bubble rendering.
- **`ChatNotifier` / `chatProvider`**: Manages message list and persona selection. Needs upgrade for true streaming token buffering, cancellation tokens, retry/regenerate, and persistent storage.

### 3.2 Glint Subsystem (`lib/features/glint/`)
- **`GlintScreen`**: Vertical swipeable short reels UI with topic filters (Stress Relief, Focus, Discipline, Mindfulness).
- **Integration Target**: Connect to `GlintGenerator` and `GenerationCache` for structured dynamic card generation (Motivation, Quote, Daily Focus, Streak, Reflection, Small Win) and deterministic fallback cards.

### 3.3 Dashboard Subsystem (`lib/features/dashboard/`)
- **`HomeDashboardScreen`**: Shows daily greeting, streak hero, daily Stoic quote card with TTS audio playback, check-in quick actions, and navigation shortcuts.
- **Integration Target**: Replace static quote list with AI-generated daily Stoic insights and locally cached reflections.

### 3.4 Settings Subsystem (`lib/features/settings/`)
- **`SettingsScreen`**: Appearance/theme toggle, daily reminders, companion avatar preference, pacing preferences, and sign out.
- **Integration Target**: Add "Local AI & Privacy" settings panel with model status, storage manager, memory inspector, conversation wipe, and telemetry diagnostics.

---

## 4. Privacy & Offline Boundary Rules

1. **No Remote Transmission of Conversations**: Under no condition shall user chat content, voice recordings, or journal entries be transmitted via `ApiService` without explicit user opt-in.
2. **Local Memory Isolation**: AI memories and context stay in on-device storage (`AiDatabase`), editable and clearable by the user at any time.
3. **Graceful Fallback**: All AI-enhanced screens (Glint, Chat, Dashboard, Journal) must function seamlessly offline with bundled deterministic fallbacks if the local LLM model is missing or unloading.
