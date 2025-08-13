import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/offline_banner.dart';

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
			final res = await Supabase.instance.client.auth.signUp(email: email.text.trim(), password: password.text.trim());
			final user = res.user;
			if (user != null) {
				await Supabase.instance.client.from('profiles').upsert({
					'user_id': user.id,
					'role': 'patient',
				});
			}
			if (!mounted) return;
			context.go('/signin');
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