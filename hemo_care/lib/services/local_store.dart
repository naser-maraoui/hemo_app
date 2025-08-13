import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
	static Future<void> init() async {
		await Hive.initFlutter();
		await Future.wait([
			Hive.openBox('user'),
			Hive.openBox('cache_articles'),
			Hive.openBox('cache_messages'),
			Hive.openBox('cache_posts'),
			Hive.openBox('cache_comments'),
		]);
	}

	static Box get userBox => Hive.box('user');
	static Box get articlesBox => Hive.box('cache_articles');
	static Box get messagesBox => Hive.box('cache_messages');
	static Box get postsBox => Hive.box('cache_posts');
	static Box get commentsBox => Hive.box('cache_comments');

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

	static Future<void> setGeneralChannelId(int id) async {
		await userBox.put('general_channel_id', id);
	}

	static int? getGeneralChannelId() {
		return (userBox.get('general_channel_id') as int?);
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

	static Future<void> cachePosts(List<Map<String, dynamic>> posts) async {
		await postsBox.put('list', posts);
	}

	static List<Map<String, dynamic>> getCachedPosts() {
		final List<dynamic>? raw = postsBox.get('list');
		return raw?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
	}

	static Future<void> cacheComments(int postId, List<Map<String, dynamic>> comments) async {
		await commentsBox.put('post_$postId', comments);
	}

	static List<Map<String, dynamic>> getCachedComments(int postId) {
		final List<dynamic>? raw = commentsBox.get('post_$postId');
		return raw?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
	}
}