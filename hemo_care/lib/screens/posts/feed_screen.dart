import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../services/local_store.dart';

class FeedScreen extends StatefulWidget {
	const FeedScreen({super.key});
	@override
	State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
	List<Map<String, dynamic>> posts = [];
	bool loading = true;
	final TextEditingController controller = TextEditingController();

	@override
	void initState() {
		super.initState();
		posts = LocalStore.getCachedPosts();
		_load();
	}

	Future<void> _load() async {
		try {
			if (kSupabaseConfigured) {
				final rows = await Supabase.instance.client.from('posts').select('id, body, created_at, author_id').order('created_at');
				posts = (rows as List).cast<Map<String, dynamic>>();
				await LocalStore.cachePosts(posts);
			}
		} catch (_) {} finally {
			if (mounted) setState(() => loading = false);
		}
	}

	Future<void> _createPost() async {
		final body = controller.text.trim();
		if (body.isEmpty || !kSupabaseConfigured) return;
		final uid = Supabase.instance.client.auth.currentUser?.id;
		if (uid == null) return;
		await Supabase.instance.client.from('posts').insert({'body': body, 'author_id': uid});
		controller.clear();
		await _load();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Posts')),
			body: Column(children: [
				Padding(
					padding: const EdgeInsets.all(12),
					child: Row(children: [
						Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Share something...'))),
						IconButton(onPressed: _createPost, icon: const Icon(Icons.send))
					]),
				),
				Expanded(
					child: loading && posts.isEmpty
						? const Center(child: CircularProgressIndicator())
						: ListView.builder(
							itemCount: posts.length,
							itemBuilder: (c, i) {
								final p = posts[i];
								return Card(
									child: ExpansionTile(
										title: Text(p['body'] ?? ''),
										subtitle: Text(p['created_at'] ?? ''),
										children: [
											_Comments(postId: (p['id'] as num).toInt()),
										],
									),
								);
							},
						),
					),
			]),
		);
	}
}

class _Comments extends StatefulWidget {
	const _Comments({required this.postId});
	final int postId;
	@override
	State<_Comments> createState() => _CommentsState();
}

class _CommentsState extends State<_Comments> {
	List<Map<String, dynamic>> comments = [];
	final TextEditingController controller = TextEditingController();

	@override
	void initState() {
		super.initState();
		comments = LocalStore.getCachedComments(widget.postId);
		_load();
	}

	Future<void> _load() async {
		try {
			if (kSupabaseConfigured) {
				final rows = await Supabase.instance.client.from('comments').select('id, body, created_at, author_id, post_id').eq('post_id', widget.postId).order('created_at');
				comments = (rows as List).cast<Map<String, dynamic>>();
				await LocalStore.cacheComments(widget.postId, comments);
			}
		} catch (_) {}
		if (mounted) setState(() {});
	}

	Future<void> _create() async {
		final body = controller.text.trim();
		if (body.isEmpty || !kSupabaseConfigured) return;
		final uid = Supabase.instance.client.auth.currentUser?.id;
		if (uid == null) return;
		await Supabase.instance.client.from('comments').insert({'body': body, 'author_id': uid, 'post_id': widget.postId});
		controller.clear();
		await _load();
	}

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			child: Column(children: [
				Row(children: [
					Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Comment...'))),
					IconButton(onPressed: _create, icon: const Icon(Icons.send))
				]),
				ListView.builder(
					shrinkWrap: true,
					physics: const NeverScrollableScrollPhysics(),
					itemCount: comments.length,
					itemBuilder: (c, i) {
						final r = comments[i];
						return ListTile(title: Text(r['body'] ?? ''));
					},
				),
			]),
		);
	}
}