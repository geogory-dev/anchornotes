import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Theme mode
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // View preferences
  bool _isGridView = true;
  bool get isGridView => _isGridView;

  double _fontSize = 14.0;
  double get fontSize => _fontSize;

  // Note preferences
  bool _autoSave = true;
  bool get autoSave => _autoSave;

  String _defaultExportFormat = 'pdf';
  String get defaultExportFormat => _defaultExportFormat;

  // Initialize settings
  Future<void> init() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeIndex = prefs.getInt('theme_mode') ?? 2; // 0=light, 1=dark, 2=system
    _themeMode = ThemeMode.values[themeIndex];
    
    // Load view preferences
    _isGridView = prefs.getBool('is_grid_view') ?? true;
    _fontSize = prefs.getDouble('font_size') ?? 14.0;
    
    // Load note preferences
    _autoSave = prefs.getBool('auto_save') ?? true;
    _defaultExportFormat = prefs.getString('default_export_format') ?? 'pdf';
    
    notifyListeners();
  }

  // Theme setters
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    await _saveThemeMode();
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
  }

  // View setters
  Future<void> setIsGridView(bool isGridView) async {
    _isGridView = isGridView;
    await _saveIsGridView();
    notifyListeners();
  }

  Future<void> _saveIsGridView() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_grid_view', _isGridView);
  }

  Future<void> setFontSize(double fontSize) async {
    _fontSize = fontSize;
    await _saveFontSize();
    notifyListeners();
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', _fontSize);
  }

  // Note preference setters
  Future<void> setAutoSave(bool autoSave) async {
    _autoSave = autoSave;
    await _saveAutoSave();
    notifyListeners();
  }

  Future<void> _saveAutoSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_save', _autoSave);
  }

  Future<void> setDefaultExportFormat(String format) async {
    _defaultExportFormat = format;
    await _saveDefaultExportFormat();
    notifyListeners();
  }

  Future<void> _saveDefaultExportFormat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_export_format', _defaultExportFormat);
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Reset to defaults
    _themeMode = ThemeMode.system;
    _isGridView = true;
    _fontSize = 14.0;
    _autoSave = true;
    _defaultExportFormat = 'pdf';
    
    notifyListeners();
  }
}
