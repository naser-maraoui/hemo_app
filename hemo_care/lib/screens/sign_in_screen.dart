import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/offline_banner.dart';

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