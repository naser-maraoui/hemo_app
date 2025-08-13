import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_store.dart';

bool kSupabaseConfigured = false;

Future<void> initSupabaseFromEnv() async {
	final String url = const String.fromEnvironment('SUPABASE_URL');
	final String anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
	if (url.isNotEmpty && anonKey.isNotEmpty) {
		await Supabase.initialize(url: url, anonKey: anonKey);
		kSupabaseConfigured = true;
	}
}

Future<String> fetchAndCacheUserRole() async {
	final uid = Supabase.instance.client.auth.currentUser?.id;
	final email = Supabase.instance.client.auth.currentUser?.email ?? '';
	if (uid == null) return 'patient';
	try {
		final profile = await Supabase.instance.client.from('profiles').select('role').eq('user_id', uid).maybeSingle();
		final role = (profile?['role'] as String?) ?? 'patient';
		await LocalStore.saveUser(userId: uid, email: email, role: role);
		return role;
	} catch (_) {
		return (LocalStore.getUser()?['role'] as String?) ?? 'patient';
	}
}