import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SettingsService _settingsService = SettingsService();
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildAccountCard(user),
          const SizedBox(height: 24),
          
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          
          // Note Preferences Section
          _buildSectionHeader('Note Preferences'),
          _buildNotePreferencesSection(),
          const SizedBox(height: 24),
          
          // Storage & Sync Section
          _buildSectionHeader('Storage & Sync'),
          _buildStorageSection(),
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('About'),
          _buildAboutSection(),
          const SizedBox(height: 32),
          
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildAccountCard(user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'guest@example.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Theme Mode
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: Text(_getThemeModeText(_settingsService.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showThemeDialog,
            ),
            const Divider(height: 1),
            
            // View Mode
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Default View'),
              subtitle: Text(_settingsService.isGridView ? 'Grid View' : 'List View'),
              trailing: Switch(
                value: _settingsService.isGridView,
                onChanged: (value) async {
                  await _settingsService.setIsGridView(value);
                },
              ),
            ),
            const Divider(height: 1),
            
            // Font Size
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Font Size'),
              subtitle: Text('${_settingsService.fontSize.toInt()}px'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showFontSizeDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotePreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Auto-save
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('Auto-save'),
              subtitle: const Text('Automatically save notes while typing'),
              trailing: Switch(
                value: _settingsService.autoSave,
                onChanged: (value) async {
                  await _settingsService.setAutoSave(value);
                },
              ),
            ),
            const Divider(height: 1),
            
            // Default Export Format
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Default Export Format'),
              subtitle: Text(_settingsService.defaultExportFormat.toUpperCase()),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showExportFormatDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Sync Status
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Status'),
              subtitle: const Text('All notes synced'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Connected',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            
            // Clear Cache
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showClearCacheDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Version
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),
            const Divider(height: 1),
            
            
          ],
        ),
      ),
    );
  }

  
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(ThemeMode.light, 'Light'),
            _buildThemeOption(ThemeMode.dark, 'Dark'),
            _buildThemeOption(ThemeMode.system, 'System Default'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: _settingsService.themeMode,
      onChanged: (value) async {
        await _settingsService.setThemeMode(value!);
        Navigator.pop(context);
      },
    );
  }

  void _showFontSizeDialog() {
    double tempFontSize = _settingsService.fontSize;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${tempFontSize.toInt()}px'),
              Slider(
                value: tempFontSize,
                min: 12.0,
                max: 20.0,
                divisions: 8,
                onChanged: (value) {
                  setState(() {
                    tempFontSize = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _settingsService.setFontSize(tempFontSize);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormatOption('pdf'),
            _buildFormatOption('txt'),
            _buildFormatOption('md'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format) {
    return RadioListTile<String>(
      title: Text(format.toUpperCase()),
      value: format,
      groupValue: _settingsService.defaultExportFormat,
      onChanged: (value) async {
        await _settingsService.setDefaultExportFormat(value!);
        Navigator.pop(context);
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear temporary files and free up storage space. Your notes will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
