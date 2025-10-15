# SyncPad - Quick Start Guide

## 🚀 Running the App

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart 3.7.0 or higher
- Android Studio / VS Code with Flutter extension
- Android emulator or physical device

### Installation & Run

```bash
# Navigate to project directory
cd C:\anchornotes

# Get dependencies (already done)
flutter pub get

# Run the app
flutter run
```

### First Time Setup (Already Complete)
```bash
# Code generation (already done)
dart run build_runner build --delete-conflicting-outputs
```

---

## 📱 App Features (Phase 1)

### What You Can Do
- ✅ Write and edit notes with a distraction-free interface
- ✅ Auto-save after 2 seconds of inactivity
- ✅ Switch between light and dark themes (follows system)
- ✅ All data stored locally (works offline)
- ✅ Data persists across app restarts

### Current Limitations (Phase 1 MVP)
- Single note only (ID: 1)
- No note list view yet (coming in Phase 2)
- No delete functionality yet
- No search yet
- No sync/collaboration yet

---

## 🗂️ Project Structure

```
lib/
├── main.dart                      # App entry point, initialization
├── models/
│   ├── note.dart                  # Note data model
│   └── note.g.dart                # Generated Isar schema
├── screens/
│   └── note_editor_screen.dart    # Main editor UI
├── services/
│   └── isar_service.dart          # Database operations
└── theme/
    ├── app_colors.dart            # Color palette
    └── app_theme.dart             # Theme configuration
```

---

## 🎨 Design System

### Colors
**Light Mode:**
- Background: `#F7F7F7`
- Text: `#2C3E50`
- Accent: `#3498DB`

**Dark Mode:**
- Background: `#1C1C1E`
- Text: `#ECF0F1`
- Accent: `#3498DB`

### Typography
- Title: 24px, SemiBold
- Content: 16px, Regular
- All using Inter font family

---

## 🔧 Development Commands

### Run App
```bash
flutter run                    # Run on connected device
flutter run -d chrome          # Run on Chrome (web)
flutter run -d windows         # Run on Windows desktop
```

### Code Quality
```bash
flutter analyze                # Check for issues
flutter test                   # Run tests
flutter format lib/            # Format code
```

### Build
```bash
flutter build apk              # Build Android APK
flutter build appbundle        # Build Android App Bundle
flutter build ios              # Build iOS (requires Mac)
flutter build windows          # Build Windows desktop
```

### Database
```bash
# Regenerate Isar schema (if you modify note.dart)
dart run build_runner build --delete-conflicting-outputs
```

---

## 🐛 Troubleshooting

### Issue: App won't build
**Solution:** Run `flutter clean && flutter pub get`

### Issue: Database errors
**Solution:** Uninstall app and reinstall (clears old database)

### Issue: Code generation fails
**Solution:** 
```bash
flutter clean
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Hot reload not working
**Solution:** Use hot restart (Ctrl+Shift+F5) or full restart

---

## 📊 Database Info

### Location
- **Android:** `/data/data/com.example.anchornotes/files/syncpad_db.isar`
- **iOS:** `~/Library/Application Support/syncpad_db.isar`
- **Windows:** `%APPDATA%/anchornotes/syncpad_db.isar`

### Schema
```dart
Note {
  Id id;                    // Auto-increment
  String title;             // Note title
  String content;           // Note body
  DateTime createdAt;       // Creation timestamp
  DateTime updatedAt;       // Last edit timestamp
}
```

### Viewing Database
Use Isar Inspector (coming in future updates) or query directly:
```dart
final notes = await IsarService().getAllNotes();
print(notes);
```

---

## 🔄 Git Workflow

### Current Commits
```
89764b2 - Add Phase 1 completion documentation and fix tests
038f611 - Phase 1 Complete: Offline-first foundation with Isar database
```

### Making Changes
```bash
git status                     # Check changes
git add .                      # Stage all changes
git commit -m "Your message"   # Commit
git log --oneline              # View history
```

---

## 📚 Key Files to Know

### For UI Changes
- `lib/screens/note_editor_screen.dart` - Main editor interface
- `lib/theme/app_theme.dart` - Theme customization
- `lib/theme/app_colors.dart` - Color palette

### For Data Changes
- `lib/models/note.dart` - Note structure
- `lib/services/isar_service.dart` - Database operations

### For App Configuration
- `lib/main.dart` - App initialization
- `pubspec.yaml` - Dependencies

---

## 🎯 Next Steps

### Phase 2 Preview
- Build HomeScreen with notes list
- Add FAB to create new notes
- Implement note deletion
- Add search functionality
- Create empty state UI

### How to Contribute
1. Create a new branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test thoroughly
4. Commit with clear messages
5. Merge back to master

---

## 💡 Tips

### Performance
- Auto-save debounces at 2 seconds - optimal for most use cases
- Database operations are async - UI stays responsive
- Indexed fields make searches fast

### UX
- Title field auto-focuses on new notes
- Back button force-saves immediately
- Visual feedback shows save status
- Themes follow system preference

### Development
- Use hot reload (r) for UI changes
- Use hot restart (R) for logic changes
- Check `flutter doctor` if issues arise
- Use `flutter pub outdated` to check for updates

---

## 📞 Support

### Documentation
- **Design System:** `SyncPad_Design_System.md`
- **Visual Mockups:** `SyncPad_Visual_Mockups.md`
- **Phase 1 Summary:** `PHASE1_COMPLETE.md`

### Resources
- [Flutter Docs](https://docs.flutter.dev/)
- [Isar Docs](https://isar.dev/)
- [Material Design 3](https://m3.material.io/)

---

**Last Updated:** October 15, 2025  
**Version:** Phase 1 Complete  
**Status:** Production Ready ✅
