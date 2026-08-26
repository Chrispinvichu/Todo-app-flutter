# Todo App — Flutter

A cross-platform (Android/iOS) task management app built with Flutter and Dart, featuring task categorization, reminders, and persistent local storage.

## Features

- **Add, complete, and delete tasks** with a swipe-to-delete list
- **Task categorization** — Work, Personal, Study, Health, Other — filterable via tabs
- **Reminders** — schedule a local notification for any task using `flutter_local_notifications`
- **Persistent storage** — all tasks are stored locally in SQLite via `sqflite`, so data survives app restarts
- **State management** — `provider` package manages app-wide task state

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Material 3) |
| Language | Dart |
| Local database | SQLite (`sqflite`) |
| Notifications | `flutter_local_notifications` |
| State management | `provider` |

## Project Structure

```
lib/
  main.dart                     # App entry point
  models/
    task.dart                   # Task model + category enum
  services/
    database_helper.dart        # SQLite CRUD operations
    notification_service.dart   # Local notification scheduling
    task_provider.dart          # App state (ChangeNotifier)
  screens/
    home_screen.dart            # Task list with category tabs
    add_task_screen.dart        # New task form
  widgets/
    task_tile.dart               # Single task list item
```

## Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
2. Clone this repo and install dependencies:
   ```bash
   flutter pub get
   ```
3. Run on a connected device or emulator:
   ```bash
   flutter run
   ```

## Notes

- Minimum SDK: Android API 21+ / iOS 12+
- Notification scheduling uses exact alarms on Android; the `SCHEDULE_EXACT_ALARM` permission is declared in the manifest.
