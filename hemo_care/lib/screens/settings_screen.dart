import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends ConsumerWidget {
	const SettingsScreen({super.key});
	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final ThemeMode themeMode = ref.watch(themeModeProvider);
		return Scaffold(
			appBar: AppBar(title: Text('settings'.tr())),
			body: ListView(
				children: [
					ListTile(
						leading: const Icon(Icons.person_outline),
						title: Text(tr('full_name')),
						subtitle: const Text('Profile'),
						onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
					),
					const Divider(),
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
					const Divider(),
					if (kSupabaseConfigured)
						ListTile(
							leading: const Icon(Icons.logout),
							title: Text(tr('logout')),
							onTap: () async {
								await Supabase.instance.client.auth.signOut();
								if (context.mounted) context.go('/signin');
							},
						),
				],
			),
		);
	}
}