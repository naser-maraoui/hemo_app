import 'package:supabase_flutter/supabase_flutter.dart';

bool kSupabaseConfigured = false;

Future<void> initSupabaseFromEnv() async {
	final String url = const String.fromEnvironment('SUPABASE_URL');
	final String anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
	if (url.isNotEmpty && anonKey.isNotEmpty) {
		await Supabase.initialize(url: url, anonKey: anonKey);
		kSupabaseConfigured = true;
	}
}