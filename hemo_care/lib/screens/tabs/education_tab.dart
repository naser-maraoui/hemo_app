import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../services/local_store.dart';
import '../article_detail_screen.dart';

class EducationTab extends StatefulWidget {
	const EducationTab({super.key});
	@override
	State<EducationTab> createState() => _EducationTabState();
}

class _EducationTabState extends State<EducationTab> {
	List<Map<String, dynamic>> articles = [];
	bool loading = true;

	@override
	void initState() {
		super.initState();
		articles = LocalStore.getCachedArticles();
		_load();
	}

	Future<void> _load() async {
		try {
			if (kSupabaseConfigured) {
				final rows = await Supabase.instance.client
					.from('articles')
					.select('id, title, body, category, created_at, created_by, profiles:created_by(full_name, avatar_url)')
					.eq('visible', true)
					.order('created_at');
				articles = (rows as List).cast<Map<String, dynamic>>();
				await LocalStore.cacheArticles(articles);
			}
		} catch (_) {
			// use cached
		} finally {
			if (mounted) setState(() => loading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('education'.tr())),
			body: loading && articles.isEmpty
				? const Center(child: CircularProgressIndicator())
				: ListView.separated(
					padding: const EdgeInsets.all(12),
					itemCount: articles.length,
					separatorBuilder: (_, __) => const SizedBox(height: 8),
					itemBuilder: (c, i) {
						final a = articles[i];
						final author = a['profiles'] as Map<String, dynamic>?;
						return Card(
							child: ListTile(
								leading: author?['avatar_url'] != null ? CircleAvatar(backgroundImage: NetworkImage(author!['avatar_url'])) : const CircleAvatar(child: Icon(Icons.person)),
								title: Text(a['title'] ?? ''),
								subtitle: Text(author?['full_name'] ?? (a['category'] ?? '')),
								onTap: () => Navigator.of(context).push(MaterialPageRoute(
									builder: (_) => ArticleDetailScreen(articleId: (a['id'] as num?)?.toInt() ?? 0, title: a['title'] ?? ''),
								)),
							),
						);
					},
				),
		);
	}
}