import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../services/local_store.dart';
import '../../services/chat_service.dart';

class ChatTab extends StatefulWidget {
	const ChatTab({super.key});
	@override
	State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
	final TextEditingController text = TextEditingController();
	int? channelId;
	String? error;

	@override
	void initState() {
		super.initState();
		_init();
	}

	Future<void> _init() async {
		final id = await ChatService.ensureGeneralChannel();
		if (mounted) setState(() => channelId = id);
	}

	@override
	Widget build(BuildContext context) {
		final int? id = channelId ?? LocalStore.getGeneralChannelId();
		return Scaffold(
			appBar: AppBar(title: Text('chat'.tr())),
			body: Column(children: [
				if (error != null) Container(color: Colors.red[100], padding: const EdgeInsets.all(8), child: Text(error!, style: const TextStyle(color: Colors.red))),
				Expanded(child: id == null ? const Center(child: CircularProgressIndicator()) : (kSupabaseConfigured ? _OnlineMessages(channelId: id) : _OfflineMessages(channelId: id))),
				Row(
					children: [
						Expanded(child: TextField(controller: text, decoration: InputDecoration(hintText: tr('chat')))),
						IconButton(onPressed: () => _send(id), icon: const Icon(Icons.send))
					],
				),
			]),
		);
	}

	Future<void> _send(int? id) async {
		final body = text.text.trim();
		if (body.isEmpty || id == null) return;
		if (!kSupabaseConfigured) return;
		final uid = Supabase.instance.client.auth.currentUser?.id;
		if (uid == null) return;
		try {
			await Supabase.instance.client.from('messages').insert({'channel_id': id, 'sender_id': uid, 'body': body});
			text.clear();
			setState(() => error = null);
		} catch (e) {
			setState(() => error = e.toString());
		}
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