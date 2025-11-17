# AnchorNotes Release Guide

This guide will help you release your AnchorNotes APK to GitHub using automated workflows.

## Prerequisites

1. **Git Repository**: Make sure your project is properly initialized with Git
2. **GitHub Repository**: Your project should be pushed to GitHub
3. **Version Management**: Update version numbers in `pubspec.yaml` before release

## Quick Release Process

### 1. Update Version Number

Edit `pubspec.yaml` to update your app version:

```yaml
version: 1.0.0+2  # Increment build number (+2) and/or version (1.0.0)
```

- The first part (1.0.0) is the version name users see
- The second part (+2) is the build number (must increase with each release)

### 2. Commit and Push Changes

```bash
git add .
git commit -m "Release v1.0.0: Fixed profile icon in dark mode"
git push origin main
```

### 3. Create and Push Version Tag

```bash
# Create a tag for the release
git tag v1.0.0

# Push the tag to GitHub
git push origin v1.0.0
```

### 4. Automatic Build Process

Once you push the tag:
1. GitHub Actions will automatically trigger the build workflow
2. The workflow will build multiple APK variants:
   - `app-release.apk` (Universal APK)
   - `app-arm64-v8a-release.apk` (64-bit ARM devices)
   - `app-armeabi-v7a-release.apk` (32-bit ARM devices)
   - `app-x86_64-release.apk` (64-bit x86 devices)

### 5. Download APKs

After the build completes (usually 5-10 minutes):
1. Go to your repository on GitHub
2. Click on "Releases" section
3. You'll find your release with all APK files ready for download

## Manual Build (Alternative)

If you want to build locally instead of using GitHub Actions:

```bash
# Get dependencies
flutter pub get

# Generate required code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release

# Find your APK at: build/app/outputs/flutter-apk/app-release.apk
```

## Version Naming Convention

Use semantic versioning: `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking changes (2.0.0)
- **MINOR**: New features (1.1.0)  
- **PATCH**: Bug fixes (1.0.1)

Examples:
- `v1.0.0` - First stable release
- `v1.0.1` - Bug fix release
- `v1.1.0` - Feature update
- `v2.0.0` - Major update with breaking changes

## Release Checklist

Before each release:

- [ ] Update version in `pubspec.yaml`
- [ ] Test app on both light and dark themes
- [ ] Verify all features work correctly
- [ ] Update CHANGELOG.md with release notes
- [ ] Commit all changes
- [ ] Create and push version tag

## APK File Types Explained

- **Universal APK** (`app-release.apk`): Works on all devices but larger file size
- **Split APKs**: Smaller files optimized for specific device architectures:
  - `arm64-v8a`: Most modern Android devices (recommended)
  - `armeabi-v7a`: Older Android devices
  - `x86_64`: Rare, for tablets/laptops with x86 processors

## Troubleshooting

### Build Fails
- Check if all dependencies are up to date: `flutter pub upgrade`
- Verify Firebase configuration is correct
- Check if there are any syntax errors in your code

### Tag Not Triggering Build
- Make sure tag format matches `v*` (e.g., v1.0.0, v1.0.1)
- Verify the tag was pushed: `git push origin --tags`

### APK Not Installing
- Ensure you're using the release APK (not debug)
- Check if app permissions are properly configured
- Verify minimum Android version requirements

## Next Steps

After successful release:

1. **Monitor Issues**: Watch GitHub for user feedback and bug reports
2. **Analytics**: If you have analytics set up, monitor adoption
3. **Next Version**: Start planning your next release based on user feedback

## Security Notes

- The workflow uses your repository's default GITHUB_TOKEN
- No additional secrets required for basic APK building
- Keep your Firebase configuration files secure
- Never commit sensitive API keys to public repositories
