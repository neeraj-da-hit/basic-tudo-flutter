<img width="400"  alt="Simulator Screenshot - iPhone 15 Pro Max - 2025-10-05 at 01 18 57" src="https://github.com/user-attachments/assets/684d153f-336c-49d8-91b1-1bb18afee8a3" />
<img width="400"  alt="Simulator Screenshot - iPhone 15 Pro Max - 2025-10-05 at 01 19 03" src="https://github.com/user-attachments/assets/75054afd-2ece-461a-8f64-f5944bd1b8b6" />
<img width="400"  alt="Simulator Screenshot - iPhone 15 Pro Max - 2025-10-05 at 01 19 11" src="https://github.com/user-attachments/assets/18515941-3006-467c-b5e5-8c59122bc700" />
<img width="400"  alt="Simulator Screenshot - iPhone 15 Pro Max - 2025-10-05 at 01 19 16" src="https://github.com/user-attachments/assets/14edfd06-867f-4562-9e06-759cee6bf102" />
<img width="400"  alt="Simulator Screenshot - iPhone 15 Pro Max - 2025-10-05 at 01 19 25" src="https://github.com/user-attachments/assets/2ef63250-28a4-4b51-ab0d-3304527a5214" />
<img width="400"  alt="Simulator Screenshot - iPhone 15 Pro Max - 2025-10-05 at 01 19 36" src="https://github.com/user-attachments/assets/fe46e609-518e-41c4-8366-bb62412ae926" />

# todo

Doto — Simple Todo app (Flutter)

Overview

Doto is a small, local-first Todo app built with Flutter. It’s focused on being easy to use and easy to read in the codebase. The app stores todos locally and uses a lightweight state management approach so it’s a good starting point for learning Flutter apps with persistent storage.

What it uses

- Flutter (Dart)
- Hive (local storage) via `hive_flutter`
- Provider (for state management)
- uuid (for stable IDs)

Key features

- Add, edit, and delete todos
- Mark todos as done/undone
- Search todos by title or note
- Clear all todos (with confirmation)
- Local persistence (data stays between app restarts)

Where to look in the code

- `lib/main.dart` — App entry point and UI (uses Provider)
- `lib/models/todo.dart` — `Todo` model and manual Hive `TypeAdapter`
- `lib/providers/todo_provider.dart` — `ChangeNotifier` that manages todos and talks to Hive
- `pubspec.yaml` — Dependencies (hive, hive_flutter, provider, uuid)

How to run (local development)

1. Make sure you have Flutter installed and an emulator or device available.

2. Fetch dependencies:

```bash
cd /Users/neerajdahit/Desktop/workspace/tutedude/todo
flutter pub get
```

3. Run the app on a device or emulator:

```bash
flutter run
```

If you have multiple devices connected, specify one with `-d <deviceId>`.

Running tests

There’s a simple widget test in `test/widget_test.dart` which checks that the app starts. Run it with:

```bash
flutter test
```

Notes and troubleshooting

- No code generation is required. The app uses a manual `TypeAdapter` for Hive so you don’t need `build_runner`.
- If you change the model and prefer generated adapters, I can switch to `hive_generator` and add `build_runner` steps.
- If the app cannot find the Hive box on startup, ensure `main()` completes Hive initialization. The project already calls `Hive.initFlutter()` and opens the `todos` box.
- To reset local data while testing, you can uninstall the app from the emulator/device or clear its app data.

Possible next improvements

- Add categories or due dates
- Add sorting and filtering options (by date, completed)
- Add unit tests for `TodoProvider`
- Add remote sync (Firebase or custom backend)

What I can help with next

- Add provider unit tests
- Improve UI styling or add animations
- Add features like due dates, categories, or notifications

If you want any changes to this README or the project, say what you'd like and I’ll update it.
