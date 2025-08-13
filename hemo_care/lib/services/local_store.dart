import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
	static Future<void> init() async {
		await Hive.initFlutter();
		await Future.wait([
			Hive.openBox('user'),
			Hive.openBox('cache_articles'),
			Hive.openBox('cache_messages'),
		]);
	}

	static Box get userBox => Hive.box('user');
	static Box get articlesBox => Hive.box('cache_articles');
	static Box get messagesBox => Hive.box('cache_messages');

	static Future<void> saveUser({required String userId, required String email, required String role}) async {
		await userBox.putAll({'user_id': userId, 'email': email, 'role': role});
	}

	static Map<String, dynamic>? getUser() {
		final String? uid = userBox.get('user_id');
		if (uid == null) return null;
		return {
			'user_id': uid,
			'email': userBox.get('email'),
			'role': userBox.get('role') ?? 'patient',
		};
	}

	static Future<void> cacheArticles(List<Map<String, dynamic>> articles) async {
		await articlesBox.put('list', articles);
	}

	static List<Map<String, dynamic>> getCachedArticles() {
		final List<dynamic>? raw = articlesBox.get('list');
		return raw?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
	}

	static Future<void> cacheMessages(int channelId, List<Map<String, dynamic>> messages) async {
		await messagesBox.put('ch_$channelId', messages);
	}

	static List<Map<String, dynamic>> getCachedMessages(int channelId) {
		final List<dynamic>? raw = messagesBox.get('ch_$channelId');
		return raw?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
	}
}