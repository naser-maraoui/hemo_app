import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
	static Future<String?> uploadAvatar(String userId, File file) async {
		final client = Supabase.instance.client;
		final String path = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
		await client.storage.from('avatars').upload(path, file, fileOptions: FileOptions(contentType: lookupMimeType(file.path)));
		final url = client.storage.from('avatars').getPublicUrl(path);
		return url;
	}

	static Future<String?> uploadPostMedia(String userId, File file) async {
		final client = Supabase.instance.client;
		final String path = 'post_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
		await client.storage.from('post_uploads').upload(path, file, fileOptions: FileOptions(contentType: lookupMimeType(file.path)));
		final url = client.storage.from('post_uploads').getPublicUrl(path);
		return url;
	}
}