# Contributing to AnchorNotes

First off, thank you for considering contributing to AnchorNotes! 🎉

It's people like you that make AnchorNotes such a great tool. We welcome contributions from everyone, whether it's:

- 🐛 Reporting a bug
- 💡 Suggesting a new feature
- 📝 Improving documentation
- 🔧 Submitting a fix
- ✨ Adding a new feature

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

---

## 📜 Code of Conduct

This project and everyone participating in it is governed by our commitment to creating a welcoming and inclusive environment. By participating, you are expected to:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- Flutter SDK (3.x or higher)
- Dart SDK (3.x or higher)
- Git
- A code editor (VS Code or Android Studio recommended)
- Firebase account (for testing)

### Setting Up Your Development Environment

1. **Fork the repository**
   - Click the "Fork" button at the top right of the repository page

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/anchornotes.git
   cd anchornotes
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/anchornotes.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Set up Firebase**
   - Follow the setup instructions in the main README.md
   - Use your own Firebase project for testing

6. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

7. **Run the app**
   ```bash
   flutter run
   ```

---

## 🤝 How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Bug Report Template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
- Device: [e.g. Pixel 6]
- OS: [e.g. Android 13]
- App Version: [e.g. 1.0.0]
- Flutter Version: [e.g. 3.16.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Features

Feature requests are welcome! Please provide:

- **Clear description** of the feature
- **Use case** - why is this feature needed?
- **Proposed solution** - how should it work?
- **Alternatives considered** - what other approaches did you think about?
- **Additional context** - mockups, examples, etc.

---

## 🔧 Development Workflow

### Branching Strategy

We use a simplified Git Flow:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent production fixes

### Creating a Feature Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name
```

### Making Changes

1. **Write clean code** following our coding standards
2. **Test thoroughly** on multiple devices/platforms
3. **Update documentation** if needed
4. **Add tests** for new features
5. **Keep commits atomic** and well-described

### Testing Your Changes

```bash
# Run tests
flutter test

# Run on device
flutter run

# Check for issues
flutter analyze

# Format code
dart format .
```

---

## 📐 Coding Standards

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- Use `lowerCamelCase` for variables, functions, and parameters
- Use `UpperCamelCase` for classes and types
- Use `lowercase_with_underscores` for file names
- Use 2 spaces for indentation
- Keep lines under 80 characters when possible

### Flutter Best Practices

- **Widgets**: Keep widgets small and focused
- **State Management**: Use ValueNotifier for simple state
- **Services**: Keep business logic in service classes
- **Models**: Use Isar entities for data models
- **Error Handling**: Always handle errors gracefully
- **Null Safety**: Leverage Dart's null safety features

### Code Organization

```
lib/
├── models/          # Data models (Isar entities)
├── services/        # Business logic
├── screens/         # Full-screen pages
├── widgets/         # Reusable UI components
└── theme/           # Styling and theming
```

### Comments and Documentation

- Add doc comments (`///`) for public APIs
- Explain **why**, not **what** in comments
- Keep comments up-to-date with code changes
- Use TODO comments for future improvements

Example:
```dart
/// Exports a note to PDF format.
///
/// The PDF includes the note title, creation date, and formatted content.
/// Uses the `printing` package to show a native print/share dialog.
///
/// Throws [Exception] if PDF generation fails.
Future<void> exportToPdf(Note note, BuildContext context) async {
  // Implementation
}
```

---

## 📝 Commit Guidelines

### Commit Message Format

Use the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```bash
feat(editor): add rich text formatting toolbar

fix(sync): resolve conflict when editing offline

docs(readme): update installation instructions

refactor(folders): simplify folder service logic
```

### Commit Best Practices

- Write clear, concise commit messages
- Keep commits focused on a single change
- Reference issue numbers when applicable
- Use present tense ("add feature" not "added feature")

---

## 🔀 Pull Request Process

### Before Submitting

- [ ] Code follows the style guidelines
- [ ] Self-review of your code
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No new warnings from `flutter analyze`
- [ ] Code formatted with `dart format`

### Submitting a Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Fill out the PR template

3. **PR Title Format**
   ```
   [Type] Brief description
   ```
   Example: `[Feature] Add PDF export functionality`

4. **PR Description Template**
   ```markdown
   ## Description
   Brief description of what this PR does.

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   Describe how you tested your changes.

   ## Screenshots (if applicable)
   Add screenshots to demonstrate UI changes.

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-reviewed my code
   - [ ] Commented complex code
   - [ ] Updated documentation
   - [ ] Added/updated tests
   - [ ] All tests pass
   - [ ] No new warnings
   ```

### Review Process

- Maintainers will review your PR
- Address any requested changes
- Keep the PR updated with `main` branch
- Once approved, a maintainer will merge

### Updating Your PR

```bash
# Fetch latest changes
git fetch upstream

# Rebase on main
git rebase upstream/main

# Force push (if needed)
git push origin feature/your-feature-name --force
```

---

## 🎯 Priority Areas

We especially welcome contributions in these areas:

### High Priority
- 🐛 Bug fixes
- 📱 iOS testing and fixes
- 🌐 Web platform improvements
- ♿ Accessibility enhancements
- 🌍 Internationalization (i18n)

### Medium Priority
- ✨ UI/UX improvements
- 📚 Documentation improvements
- 🧪 Test coverage
- ⚡ Performance optimizations

### Feature Requests
- 📎 Attachments support
- 🏷️ Tags system
- 📊 Note templates
- 🔍 Advanced search
- 📱 Widgets

---

## 🆘 Getting Help

Need help? Here's how to get support:

- 💬 **GitHub Discussions** - Ask questions, share ideas
- 🐛 **GitHub Issues** - Report bugs, request features
- 📧 **Email** - For private concerns

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Isar Database](https://isar.dev/)
- [Material Design 3](https://m3.material.io/)

---

## 🙏 Thank You!

Your contributions make AnchorNotes better for everyone. We appreciate your time and effort! 🎉

**Happy Coding!** 🚀

---

<div align="center">
  Made with ♥ by the AnchorNotes community
</div>
