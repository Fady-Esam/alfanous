# 🌙 Alfanous - Offline Quran Search Engine

A highly optimized, 100% offline-first Quran search engine and audio player built with Flutter. Designed for speed, accuracy, and a premium user experience without requiring an active internet connection.

## ✨ Core Features

* **⚡ Lightning-Fast Search (FTS5):** Utilizes SQLite Full-Text Search (FTS5) for instant, diacritic-aware, and root-based semantic search across the entire Quran.
* **🎨 Smart Highlighting:** Custom offset-mapping algorithm to precisely highlight search terms even when ignoring Arabic diacritics (Tashkeel).
* **🎧 Offline Audio (Download-on-Demand):** Users can download recitations for specific Ayahs once, and play them offline forever. Supports multiple reciters.
* **📜 Infinite Scrolling:** Smooth pagination that effortlessly handles thousands of search results with zero memory leaks or UI jank.
* **⚙️ Premium Settings:** Reactive, locally-persisted settings for customizable font sizes and reciter preferences.
* **🌙 Pure Dark Mode:** A sleek, focused, and battery-friendly UI designed for extended reading and searching.

## 🛠️ Tech Stack & Architecture

* **Framework:** Flutter (Dart)
* **State Management:** `flutter_bloc` (Cubits for clean, reactive states)
* **Local Database:** `sqflite` (Pre-populated assets with FTS5 virtual tables)
* **Storage & Caching:** `shared_preferences`, `path_provider`
* **Audio & Network:** `just_audio` (offline playback), `dio` (file downloading)
