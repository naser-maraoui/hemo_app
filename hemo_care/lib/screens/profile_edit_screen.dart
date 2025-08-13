import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/local_store.dart';

class ProfileEditScreen extends StatefulWidget {
	const ProfileEditScreen({super.key});
	@override
	State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
	final TextEditingController name = TextEditingController();
	String role = 'patient';
	bool saving = false;

	@override
	void initState() {
		super.initState();
		final u = LocalStore.getUser();
		role = (u?['role'] as String?) ?? 'patient';
	}

	Future<void> _save() async {
		setState(() => saving = true);
		try {
			if (kSupabaseConfigured) {
				final uid = Supabase.instance.client.auth.currentUser?.id;
				if (uid != null) {
					await Supabase.instance.client.from('profiles').update({'full_name': name.text.trim()}).eq('user_id', uid);
				}
			}
		} finally {
			if (mounted) setState(() => saving = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text(tr('settings'))),
			body: ListView(
				padding: const EdgeInsets.all(16),
				children: [
					TextField(controller: name, decoration: InputDecoration(labelText: tr('full_name', args: []), hintText: 'John Doe')),
					const SizedBox(height: 12),
					InputDecorator(
						decoration: InputDecoration(labelText: tr('select_role')),
						child: Text(role),
					),
					const SizedBox(height: 12),
					FilledButton(onPressed: saving ? null : _save, child: saving ? const CircularProgressIndicator() : Text(tr('save'))),
				],
			),
		);
	}
}