import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_store.dart';
import 'supabase_service.dart';

class ChatService {
	static Future<int?> ensureGeneralChannel() async {
		if (!kSupabaseConfigured) {
			return LocalStore.getGeneralChannelId();
		}
		final client = Supabase.instance.client;
		final String? uid = client.auth.currentUser?.id;
		if (uid == null) return LocalStore.getGeneralChannelId();
		// find or create channel
		final existing = await client.from('channels').select().eq('name', 'General').eq('is_direct', false).maybeSingle();
		int channelId;
		if (existing != null && existing['id'] != null) {
			channelId = (existing['id'] as num).toInt();
		} else {
			final inserted = await client.from('channels').insert({'name': 'General', 'is_direct': false, 'created_by': uid}).select().maybeSingle();
			channelId = (inserted?['id'] as num).toInt();
		}
		// ensure membership via upsert
		await client.from('channel_members').upsert({'channel_id': channelId, 'user_id': uid}).select();
		await LocalStore.setGeneralChannelId(channelId);
		return channelId;
	}

	static Future<List<Map<String, dynamic>>> listUsers() async {
		if (!kSupabaseConfigured) return [];
		final rows = await Supabase.instance.client.from('profiles_public').select('user_id, full_name, role');
		return (rows as List).cast<Map<String, dynamic>>();
	}

	static Future<int?> ensureDirectChannel(String otherUserId) async {
		if (!kSupabaseConfigured) return null;
		final client = Supabase.instance.client;
		final String? uid = client.auth.currentUser?.id;
		if (uid == null) return null;
		// find an existing direct channel with both members
		final channels = await client.rpc('find_direct_channel', params: {'p_user_a': uid, 'p_user_b': otherUserId});
		if (channels is List && channels.isNotEmpty) {
			return (channels.first['id'] as num).toInt();
		}
		final inserted = await client.from('channels').insert({'is_direct': true, 'created_by': uid}).select().maybeSingle();
		final int channelId = (inserted?['id'] as num).toInt();
		await client.from('channel_members').upsert({'channel_id': channelId, 'user_id': uid}).select();
		await client.from('channel_members').upsert({'channel_id': channelId, 'user_id': otherUserId}).select();
		return channelId;
	}
}