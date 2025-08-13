import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool kSupabaseConfigured = false;

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await EasyLocalization.ensureInitialized();
	await Hive.initFlutter();
	await _initSupabase();
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

Future<void> _initSupabase() async {
	final String url = const String.fromEnvironment('SUPABASE_URL');
	final String anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
	if (url.isNotEmpty && anonKey.isNotEmpty) {
		await Supabase.initialize(url: url, anonKey: anonKey);
		kSupabaseConfigured = true;
	}
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

class _AppBootstrap extends ConsumerWidget {
	const _AppBootstrap({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final ThemeMode themeMode = ref.watch(themeModeProvider);
		final router = _buildRouter();
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
	}
}

// For template test compatibility
class MyApp extends StatelessWidget {
	const MyApp({super.key});
	@override
	Widget build(BuildContext context) => const _AppBootstrap();
}

GoRouter _buildRouter() {
	return GoRouter(
		initialLocation: '/home',
		redirect: (context, state) {
			if (!kSupabaseConfigured && (state.matchedLocation.startsWith('/patient') || state.matchedLocation.startsWith('/doctor') || state.matchedLocation.startsWith('/admin'))) {
				return '/signin';
			}
			return null;
		},
		routes: [
			GoRoute(path: '/signin', builder: (ctx, st) => const SignInScreen()),
			GoRoute(path: '/signup', builder: (ctx, st) => const SignUpScreen()),
			GoRoute(path: '/home', builder: (ctx, st) => const HomeScreen()),
			GoRoute(path: '/patient', builder: (ctx, st) => const PatientHomeScreen()),
			GoRoute(path: '/doctor', builder: (ctx, st) => const DoctorHomeScreen()),
			GoRoute(path: '/admin', builder: (ctx, st) => const AdminHomeScreen()),
			GoRoute(path: '/settings', builder: (ctx, st) => const SettingsScreen()),
		],
	);
}

class OfflineBanner extends StatefulWidget {
	const OfflineBanner({super.key});

	@override
	State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
	late final Stream<List<ConnectivityResult>> _stream;
	List<ConnectivityResult> _status = const [ConnectivityResult.mobile];

	@override
	void initState() {
		super.initState();
		_stream = Connectivity().onConnectivityChanged;
		Connectivity().checkConnectivity().then((value) => setState(() => _status = value));
	}

	@override
	Widget build(BuildContext context) {
		return StreamBuilder<List<ConnectivityResult>>(
			stream: _stream,
			builder: (ctx, snap) {
				if (snap.hasData) _status = snap.data!;
				final bool isOffline = _status.length == 1 && _status.first == ConnectivityResult.none;
				return AnimatedContainer(
					duration: const Duration(milliseconds: 250),
					height: isOffline ? 28 : 0,
					color: Colors.orange,
					alignment: Alignment.center,
					child: isOffline ? Text('offline'.tr(), style: const TextStyle(color: Colors.black)) : const SizedBox.shrink(),
				);
			},
		);
	}
}

class SignInScreen extends StatefulWidget {
	const SignInScreen({super.key});
	@override
	State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
	final TextEditingController email = TextEditingController();
	final TextEditingController password = TextEditingController();
	bool loading = false;
	String? error;

	Future<void> _submit() async {
		setState(() { loading = true; error = null; });
		try {
			if (!kSupabaseConfigured) {
				throw Exception('Supabase not configured');
			}
			await Supabase.instance.client.auth.signInWithPassword(email: email.text.trim(), password: password.text.trim());
			if (!mounted) return;
			context.go('/home');
		} catch (e) {
			setState(() { error = e.toString(); });
		} finally {
			if (mounted) setState(() { loading = false; });
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('sign_in'.tr())),
			body: Column(
				children: [
					const OfflineBanner(),
					Padding(
						padding: const EdgeInsets.all(16),
						child: Column(children: [
							TextField(controller: email, decoration: InputDecoration(labelText: 'email'.tr())),
							TextField(controller: password, decoration: InputDecoration(labelText: 'password'.tr()), obscureText: true),
							const SizedBox(height: 12),
							if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
							Row(
								children: [
									Expanded(child: ElevatedButton(onPressed: loading ? null : _submit, child: loading ? const CircularProgressIndicator() : Text('sign_in'.tr()))),
								],
							),
							TextButton(onPressed: () => context.go('/signup'), child: Text('sign_up'.tr())),
						]),
					),
				],
			),
		);
	}
}

class SignUpScreen extends StatefulWidget {
	const SignUpScreen({super.key});
	@override
	State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
	final TextEditingController email = TextEditingController();
	final TextEditingController password = TextEditingController();
	final TextEditingController confirm = TextEditingController();
	bool loading = false;
	String? error;

	Future<void> _submit() async {
		if (password.text != confirm.text) {
			setState(() { error = 'Passwords do not match'; });
			return;
		}
		setState(() { loading = true; error = null; });
		try {
			if (!kSupabaseConfigured) {
				throw Exception('Supabase not configured');
			}
			await Supabase.instance.client.auth.signUp(email: email.text.trim(), password: password.text.trim());
			if (!mounted) return;
			context.go('/home');
		} catch (e) {
			setState(() { error = e.toString(); });
		} finally {
			if (mounted) setState(() { loading = false; });
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('sign_up'.tr())),
			body: Column(children: [
				const OfflineBanner(),
				Padding(
					padding: const EdgeInsets.all(16),
					child: Column(children: [
						TextField(controller: email, decoration: InputDecoration(labelText: 'email'.tr())),
						TextField(controller: password, decoration: InputDecoration(labelText: 'password'.tr()), obscureText: true),
						TextField(controller: confirm, decoration: InputDecoration(labelText: 'confirm_password'.tr()), obscureText: true),
						const SizedBox(height: 12),
						if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
						Row(children: [
							Expanded(child: ElevatedButton(onPressed: loading ? null : _submit, child: loading ? const CircularProgressIndicator() : Text('sign_up'.tr()))),
						]),
					]),
				),
			]),
		);
	}
}

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});
	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	String? role;
	bool loading = true;

	@override
	void initState() {
		super.initState();
		_load();
	}

	Future<void> _load() async {
		try {
			if (kSupabaseConfigured && Supabase.instance.client.auth.currentUser != null) {
				final uid = Supabase.instance.client.auth.currentUser!.id;
				final data = await Supabase.instance.client.from('profiles').select('role').eq('user_id', uid).maybeSingle();
				role = (data != null) ? (data['role'] as String?) : null;
				final prefs = await SharedPreferences.getInstance();
				if (role != null) await prefs.setString('last_role', role!);
			} else {
				final prefs = await SharedPreferences.getInstance();
				role = prefs.getString('last_role');
			}
		} catch (_) {
			final prefs = await SharedPreferences.getInstance();
			role = prefs.getString('last_role');
		} finally {
			if (mounted) setState(() { loading = false; });
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('app_title'.tr()),
				actions: [
					IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings)),
					if (kSupabaseConfigured && Supabase.instance.client.auth.currentUser != null)
						IconButton(onPressed: () async { await Supabase.instance.client.auth.signOut(); if (!mounted) return; context.go('/signin'); }, icon: const Icon(Icons.logout))
				],
			),
			body: Column(children: [
				const OfflineBanner(),
				Expanded(
					child: ListView(
						padding: const EdgeInsets.all(16),
						children: [
							Text('welcome_message'.tr(), style: Theme.of(context).textTheme.headlineSmall),
							const SizedBox(height: 16),
							Text('select_role'.tr()),
							const SizedBox(height: 8),
							Wrap(spacing: 12, runSpacing: 12, children: [
								ElevatedButton.icon(onPressed: () => context.go('/patient'), icon: const Icon(Icons.favorite), label: Text('patient'.tr())),
								ElevatedButton.icon(onPressed: () => context.go('/doctor'), icon: const Icon(Icons.medical_information), label: Text('doctor'.tr())),
								ElevatedButton.icon(onPressed: () => context.go('/admin'), icon: const Icon(Icons.admin_panel_settings), label: Text('admin'.tr())),
							]),
							if (loading) const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
							if (!loading && role != null) Text('Detected role: $role'),
						],
					),
				)
			]),
		);
	}
}

class PatientHomeScreen extends StatelessWidget {
	const PatientHomeScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('patient'.tr()), actions: [IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings))]),
			body: const Center(child: Text('Patient dashboard')),
		);
	}
}

class DoctorHomeScreen extends StatelessWidget {
	const DoctorHomeScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('doctor'.tr()), actions: [IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings))]),
			body: const Center(child: Text('Doctor dashboard')),
		);
	}
}

class AdminHomeScreen extends StatelessWidget {
	const AdminHomeScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('admin'.tr()), actions: [IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings))]),
			body: const Center(child: Text('Admin dashboard')),
		);
	}
}

class SettingsScreen extends ConsumerWidget {
	const SettingsScreen({super.key});
	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final ThemeMode themeMode = ref.watch(themeModeProvider);
		return Scaffold(
			appBar: AppBar(title: Text('settings'.tr())),
			body: ListView(
				children: [
					ListTile(title: Text('language'.tr())),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: Wrap(spacing: 8, children: [
							FilterChip(label: Text('english'.tr()), selected: context.locale.languageCode == 'en', onSelected: (_) => context.setLocale(const Locale('en'))),
							FilterChip(label: Text('french'.tr()), selected: context.locale.languageCode == 'fr', onSelected: (_) => context.setLocale(const Locale('fr'))),
							FilterChip(label: Text('arabic'.tr()), selected: context.locale.languageCode == 'ar', onSelected: (_) => context.setLocale(const Locale('ar'))),
						]),
					),
					const Divider(),
					ListTile(title: Text('theme'.tr())),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: Wrap(spacing: 8, children: [
							FilterChip(label: Text('light'.tr()), selected: themeMode == ThemeMode.light, onSelected: (_) => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light)),
							FilterChip(label: Text('dark'.tr()), selected: themeMode == ThemeMode.dark, onSelected: (_) => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark)),
							FilterChip(label: Text('system'.tr()), selected: themeMode == ThemeMode.system, onSelected: (_) => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system)),
						]),
					),
				],
			),
		);
	}
}
