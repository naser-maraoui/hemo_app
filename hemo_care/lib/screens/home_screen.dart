import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/offline_banner.dart';

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