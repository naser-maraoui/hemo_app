import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/local_store.dart';

class ArticleDetailScreen extends StatefulWidget {
	const ArticleDetailScreen({super.key, required this.articleId, required this.title});
	final int articleId;
	final String title;
	@override
	State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
	String body = '';
	bool loading = true;

	@override
	void initState() {
		super.initState();
		_load();
	}

	Future<void> _load() async {
		try {
			if (kSupabaseConfigured) {
				final rows = await Supabase.instance.client.from('articles').select('body').eq('id', widget.articleId).maybeSingle();
				body = (rows?['body'] as String?) ?? '';
			} else {
				final cached = LocalStore.getCachedArticles().firstWhere((a) => a['id'] == widget.articleId, orElse: () => {});
				body = (cached['body'] as String?) ?? '';
			}
		} catch (_) {
			body = '';
		} finally {
			if (mounted) setState(() => loading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text(widget.title)),
			body: loading
				? const Center(child: CircularProgressIndicator())
				: body.isEmpty
					? Center(child: Text(tr('education')))
					: Markdown(data: body, padding: const EdgeInsets.all(16)),
		);
	}
}