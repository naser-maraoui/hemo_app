import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(() => throw UnimplementedError());

class ThemeModeController extends Notifier<ThemeMode> {
	ThemeModeController(this.prefs, this.initialThemeMode);
	final SharedPreferences prefs;
	final ThemeMode initialThemeMode;

	@override
	ThemeMode build() => initialThemeMode;

	Future<void> setThemeMode(ThemeMode mode) async {
		state = mode;
		await prefs.setString('theme_mode', switch (mode) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system' });
	}
}