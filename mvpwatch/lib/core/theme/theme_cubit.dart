import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Emits [ThemeMode] (light / dark / system).
/// Persists the selection via shared_preferences so it survives app restarts.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode'; // persisted key

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  // ─── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    switch (stored) {
      case 'dark':
        emit(ThemeMode.dark);
      case 'system':
        emit(ThemeMode.system);
      default:
        emit(ThemeMode.light); // Clinical light theme is default
    }
  }

  Future<void> _persist(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_key, 'light');
      case ThemeMode.dark:
        await prefs.setString(_key, 'dark');
      case ThemeMode.system:
        await prefs.setString(_key, 'system');
    }
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Toggle between dark ↔ light (ignores system).
  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    _persist(next);
  }

  /// Explicitly set any [ThemeMode].
  void setTheme(ThemeMode mode) {
    emit(mode);
    _persist(mode);
  }
}
