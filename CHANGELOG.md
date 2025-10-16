# Changelog

All notable changes to AnchorNotes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Note templates
- Tags system
- Advanced search filters
- Bulk export
- Note history/versioning

---

## [1.0.0] - 2025-10-16

### 🎉 Initial Release

The first stable release of AnchorNotes with full feature set!

### ✨ Features

#### Core Functionality
- **Offline-First Architecture** - Work seamlessly without internet connection
- **Real-Time Sync** - Automatic bidirectional sync with Firestore
- **Rich Text Editor** - 20+ formatting options powered by Flutter Quill
  - Bold, italic, underline, strikethrough
  - Headings (H1, H2, H3)
  - Lists (bullet, numbered, checklist)
  - Text alignment and indentation
  - Code blocks and quotes
  - Colors and highlights
- **Auto-Save** - Changes save automatically every 2 seconds
- **Search** - Fast full-text search across all notes

#### Organization
- **Folders** - Create custom folders with icons and colors
- **Favorites** - Star important notes for quick access
- **Filters** - View all notes, favorites, or notes by folder
- **Note Count** - Real-time count of notes in each folder

#### Collaboration
- **Note Sharing** - Share notes with other users via email
- **Permission System** - Owner, Editor, and Viewer roles
- **Real-Time Updates** - See changes from collaborators instantly
- **Access Control** - Manage who can view and edit your notes

#### Export & Sharing
- **PDF Export** - Professional document generation
- **Markdown Export** - Export as `.md` files
- **Text Export** - Plain text `.txt` files
- **Native Share** - Use device share sheet for all exports

#### Authentication
- **Email/Password** - Traditional authentication
- **Google Sign-In** - One-tap sign in with Google
- **Secure** - Firebase Authentication with security rules

#### UI/UX
- **Material Design 3** - Modern, beautiful interface
- **Dark Mode** - Automatic theme switching
- **Responsive** - Works on phones, tablets, and web
- **Animations** - Smooth transitions and loading states
- **Navigation Drawer** - Clean hamburger menu
- **Error Handling** - Helpful error messages and feedback

### 🔒 Security
- **Firestore Security Rules** - Permission-based access control
- **Data Isolation** - Each user's data is completely separate
- **Secure Sharing** - Email-based collaboration only

### 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web

### 🐛 Bug Fixes
- Fixed rich text preview showing JSON in note cards
- Fixed folder note counts not updating
- Fixed sync conflicts with "Last Write Wins" strategy
- Fixed notes from other accounts appearing after sign-out
- Fixed toolbar overflow in rich text editor
- Fixed missing save indicator in editor

### 📚 Documentation
- Comprehensive README with setup instructions
- CONTRIBUTING.md for contributors
- FIRESTORE_SECURITY_RULES.md for security setup
- RICH_TEXT_SYNC_LIMITATIONS.md explaining sync strategy
- Inline code documentation

### 🏗️ Technical
- **Flutter**: 3.x
- **Dart**: 3.x
- **Firebase**: Core, Auth, Firestore
- **Isar**: 3.1.0 (local database)
- **Flutter Quill**: 9.3.20 (rich text)
- **PDF**: 3.10.8
- **Printing**: 5.12.0
- **Share Plus**: 7.2.2

---

## Development Phases

**Total Development Time:** ~6 weeks (September - October 2025)

### Phase 1: Foundation ✅ (Week 1)
- Basic Flutter setup
- Single note editor
- Local persistence with Isar

### Phase 2: Authentication ✅ (Week 2)
- Firebase Authentication
- Email/password login
- Google Sign-In
- User management

### Phase 3: Cloud Sync ✅ (Week 3)
- Firestore integration
- Bidirectional sync
- Offline-first architecture
- Conflict resolution

### Phase 4: Collaboration ✅ (Week 4)
- Multi-note management
- Note sharing
- Permission system
- Real-time collaboration
- Single source of truth refactor

### Phase 5: Polish & Refinement ✅ (Week 5)
- Animations and transitions
- Error handling
- Loading states
- Performance optimization
- App icon and splash screen
- Comprehensive documentation

### Phase 6: Enhanced Features ✅ (Week 6)
- Folders & Organization
- Favorites
- Navigation Drawer
- Rich Text Editor
- Export Features (PDF/Markdown/Text)
- Sync Documentation

---

## Migration Guide

### From Pre-1.0 Versions

If you were testing early versions:

1. **Clear local data** (optional but recommended)
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Update Firebase rules**
   - Copy new rules from `FIRESTORE_SECURITY_RULES.md`
   - Update in Firebase Console

3. **Regenerate schemas**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Sign out and sign back in** to refresh permissions

---

## Known Issues

### Rich Text Sync
- Concurrent offline edits use "Last Write Wins"
- See `RICH_TEXT_SYNC_LIMITATIONS.md` for details
- **Workaround**: Stay online when collaborating

### Platform-Specific
- iOS: Requires iOS 12.0 or higher
- Web: Some features may have limited functionality
- Android: Requires Android 5.0 (API 21) or higher

---

## Acknowledgments

Special thanks to:
- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Isar for the fast local database
- Flutter Quill for rich text editing
- All contributors and testers

---

## Links

- **Repository**: https://github.com/4LatinasOnMe/anchornotes
- **Issues**: https://github.com/4LatinasOnMe/anchornotes/issues
- **Discussions**: https://github.com/4LatinasOnMe/anchornotes/discussions

---

[Unreleased]: https://github.com/4LatinasOnMe/anchornotes/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/4LatinasOnMe/anchornotes/releases/tag/v1.0.0
