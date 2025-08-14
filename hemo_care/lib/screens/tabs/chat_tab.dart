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
	List<Map<String, dynamic>> users = [];

	@override
	void initState() {
		super.initState();
		_init();
	}

	Future<void> _init() async {
		final id = await ChatService.ensureGeneralChannel();
		final list = await ChatService.listUsers();
		if (mounted) setState(() { channelId = id; users = list; });
	}

	Future<void> _startDirect(String otherUserId) async {
		final id = await ChatService.ensureDirectChannel(otherUserId);
		if (mounted && id != null) setState(() => channelId = id);
	}

	@override
	Widget build(BuildContext context) {
		final int? id = channelId ?? LocalStore.getGeneralChannelId();
		return Scaffold(
			appBar: AppBar(title: Text('chat'.tr())),
			body: Row(children: [
				// users list
				if (kSupabaseConfigured)
					Container(
						width: 240,
						decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
						child: ListView.builder(
							itemCount: users.length,
							itemBuilder: (c, i) {
								final u = users[i];
								return ListTile(
									title: Text(u['full_name']?.toString().isNotEmpty == true ? u['full_name'] : 'User'),
									onTap: () => _startDirect(u['user_id'] as String),
								);
							},
						),
					),
				Expanded(
					child: Column(children: [
						if (error != null) Container(color: Colors.red[100], padding: const EdgeInsets.all(8), child: Text(error!, style: const TextStyle(color: Colors.red))),
						Expanded(child: id == null ? const Center(child: CircularProgressIndicator()) : (kSupabaseConfigured ? _OnlineMessages(channelId: id) : _OfflineMessages(channelId: id))),
						Row(children: [
							Expanded(child: TextField(controller: text, decoration: InputDecoration(hintText: tr('chat')))),
							IconButton(onPressed: () => _send(id), icon: const Icon(Icons.send))
						]),
					]),
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
			stream: Supabase.instance.client
				.from('messages')
				.select('id, body, created_at, sender_id, profiles:sender_id(full_name, avatar_url)')
				.eq('channel_id', channelId)
				.order('created_at')
				.asStream(),
			builder: (context, snapshot) {
				final rows = snapshot.data ?? LocalStore.getCachedMessages(channelId);
				return ListView.builder(
					padding: const EdgeInsets.all(12),
					itemCount: rows.length,
					itemBuilder: (c, i) {
						final m = rows[i];
						final mine = m['sender_id'] == Supabase.instance.client.auth.currentUser?.id;
						final author = m['profiles'] as Map<String, dynamic>?;
						return Align(
							alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
							child: Container(
								margin: const EdgeInsets.symmetric(vertical: 4),
								padding: const EdgeInsets.all(10),
								constraints: const BoxConstraints(maxWidth: 320),
								decoration: BoxDecoration(
									color: mine ? Colors.blue[200] : Colors.grey[200],
									borderRadius: BorderRadius.circular(12),
								),
								child: Row(
									mainAxisSize: MainAxisSize.min,
									crossAxisAlignment: CrossAxisAlignment.end,
									children: [
										if (!mine)
											Padding(
												padding: const EdgeInsets.only(right: 6),
												child: CircleAvatar(radius: 12, backgroundImage: (author?['avatar_url'] != null) ? NetworkImage(author!['avatar_url']) : null),
											),
										Flexible(child: Text(m['body'] ?? '')),
									],
								),
							),
						);
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