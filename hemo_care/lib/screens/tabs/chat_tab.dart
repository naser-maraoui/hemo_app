import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../services/local_store.dart';

class ChatTab extends StatefulWidget {
	const ChatTab({super.key});
	@override
	State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
	final TextEditingController text = TextEditingController();
	final int channelId = 1;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('chat'.tr())),
			body: Column(children: [
				Expanded(child: kSupabaseConfigured ? _OnlineMessages(channelId: channelId) : _OfflineMessages(channelId: channelId)),
				Row(
					children: [
						Expanded(child: TextField(controller: text, decoration: InputDecoration(hintText: tr('chat')))),
						IconButton(onPressed: _send, icon: const Icon(Icons.send))
					],
				),
			]),
		);
	}

	Future<void> _send() async {
		final body = text.text.trim();
		if (body.isEmpty) return;
		if (!kSupabaseConfigured) return;
		final uid = Supabase.instance.client.auth.currentUser?.id;
		if (uid == null) return;
		await Supabase.instance.client.from('messages').insert({'channel_id': channelId, 'sender_id': uid, 'body': body});
		text.clear();
	}
}

class _OnlineMessages extends StatelessWidget {
	const _OnlineMessages({required this.channelId});
	final int channelId;
	@override
	Widget build(BuildContext context) {
		return StreamBuilder<List<Map<String, dynamic>>>(
			stream: Supabase.instance.client.from('messages').stream(primaryKey: ['id']).eq('channel_id', channelId).order('created_at'),
			builder: (context, snapshot) {
				final rows = snapshot.data ?? LocalStore.getCachedMessages(channelId);
				if (snapshot.hasData) LocalStore.cacheMessages(channelId, rows);
				return ListView.builder(
					padding: const EdgeInsets.all(12),
					itemCount: rows.length,
					itemBuilder: (c, i) {
						final m = rows[i];
						return ListTile(title: Text(m['body'] ?? ''));
					},
				);
			},
		);
	}
}

class _OfflineMessages extends StatelessWidget {
	const _OfflineMessages({required this.channelId});
	final int channelId;
	@override
	Widget build(BuildContext context) {
		final rows = LocalStore.getCachedMessages(channelId);
		return ListView.builder(
			padding: const EdgeInsets.all(12),
			itemCount: rows.length,
			itemBuilder: (c, i) {
				final m = rows[i];
				return ListTile(title: Text(m['body'] ?? ''));
			},
		);
	}
}