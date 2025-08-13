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
	String selectedRole = 'patient';
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
					'role': selectedRole,
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
		final cs = Theme.of(context).colorScheme;
		return Scaffold(
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [cs.surfaceContainerHighest, cs.primary.withOpacity(0.08)],
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
				),
				child: SafeArea(
					child: Column(children: [
						const OfflineBanner(),
						Expanded(
							child: Center(
								child: ConstrainedBox(
									constraints: const BoxConstraints(maxWidth: 480),
									child: Card(
										margin: const EdgeInsets.all(16),
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
										child: Padding(
											padding: const EdgeInsets.all(20),
											child: Column(
												mainAxisSize: MainAxisSize.min,
												crossAxisAlignment: CrossAxisAlignment.stretch,
												children: [
													Text('sign_up'.tr(), style: Theme.of(context).textTheme.headlineSmall),
													const SizedBox(height: 8),
													Text('choose_role_signup'.tr(), style: Theme.of(context).textTheme.labelLarge),
													const SizedBox(height: 8),
													Wrap(spacing: 8, children: [
														ChoiceChip(label: Text('patient'.tr()), selected: selectedRole == 'patient', onSelected: (_) => setState(() => selectedRole = 'patient')),
														ChoiceChip(label: Text('doctor'.tr()), selected: selectedRole == 'doctor', onSelected: (_) => setState(() => selectedRole = 'doctor')),
													]),
													const SizedBox(height: 16),
													TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(prefixIcon: const Icon(Icons.email_outlined), labelText: 'email'.tr())),
													const SizedBox(height: 12),
													TextField(controller: password, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), labelText: 'password'.tr()), obscureText: true),
													const SizedBox(height: 12),
													TextField(controller: confirm, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_reset), labelText: 'confirm_password'.tr()), obscureText: true),
													const SizedBox(height: 12),
													if (error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
													FilledButton(
														onPressed: loading ? null : _submit,
														child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('sign_up'.tr()),
													),
													TextButton(onPressed: () => context.go('/signin'), child: Text('sign_in'.tr())),
												],
											),
										),
									),
								),
							),
						),
					]),
				),
			),
		);
	}
}