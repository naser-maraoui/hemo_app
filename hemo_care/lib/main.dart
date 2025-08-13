import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/theme_provider.dart';
import 'services/supabase_service.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/patient_home_screen.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/shell_screen.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await EasyLocalization.ensureInitialized();
	await initSupabaseFromEnv();
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	final ThemeMode initialThemeMode = _readSavedThemeMode(prefs);

	runApp(
		EasyLocalization(
			 supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
			 path: 'assets/translations',
			 fallbackLocale: const Locale('en'),
			 child: ProviderScope(
				 overrides: [themeModeProvider.overrideWith(() => ThemeModeController(prefs, initialThemeMode))],
				 child: const _AppBootstrap(),
			 ),
		),
	);
}

ThemeMode _readSavedThemeMode(SharedPreferences prefs) {
	final String? value = prefs.getString('theme_mode');
	switch (value) {
		case 'light':
			return ThemeMode.light;
		case 'dark':
			return ThemeMode.dark;
		default:
			return ThemeMode.system;
	}
}

class _AppBootstrap extends ConsumerWidget {
	const _AppBootstrap({super.key});

	Future<String> _initialLocation() async {
		final prefs = await SharedPreferences.getInstance();
		final seen = prefs.getBool('seen_onboarding') ?? false;
		return seen ? '/signin' : '/onboarding';
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final ThemeMode themeMode = ref.watch(themeModeProvider);
		return FutureBuilder<String>(
			future: _initialLocation(),
			builder: (context, snap) {
				final router = _buildRouter(initial: snap.data ?? '/onboarding');
				return MaterialApp.router(
					title: 'Hemophilia Care',
					debugShowCheckedModeBanner: false,
					locale: context.locale,
					supportedLocales: context.supportedLocales,
					localizationsDelegates: context.localizationDelegates,
					themeMode: themeMode,
					theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
					darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark), useMaterial3: true),
					routerConfig: router,
				);
			},
		);
	}
}

GoRouter _buildRouter({required String initial}) {
	return GoRouter(
		initialLocation: initial,
		routes: [
			GoRoute(path: '/onboarding', builder: (ctx, st) => const OnboardingScreen()),
			GoRoute(path: '/signin', builder: (ctx, st) => const SignInScreen()),
			GoRoute(path: '/signup', builder: (ctx, st) => const SignUpScreen()),
			GoRoute(path: '/home', builder: (ctx, st) => const HomeScreen()),
			GoRoute(path: '/shell', builder: (ctx, st) => const ShellScreen()),
			GoRoute(path: '/patient', builder: (ctx, st) => const PatientHomeScreen()),
			GoRoute(path: '/doctor', builder: (ctx, st) => const DoctorHomeScreen()),
			GoRoute(path: '/admin', builder: (ctx, st) => const AdminHomeScreen()),
			GoRoute(path: '/settings', builder: (ctx, st) => const SettingsScreen()),
		],
	);
}
