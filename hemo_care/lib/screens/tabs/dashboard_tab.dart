import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../posts/feed_screen.dart';

class DashboardTab extends StatelessWidget {
	const DashboardTab({super.key});
	@override
	Widget build(BuildContext context) {
		return CustomScrollView(
			slivers: [
				SliverToBoxAdapter(
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Text('dashboard'.tr(), style: Theme.of(context).textTheme.headlineSmall),
					),
				),
				SliverPadding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					sliver: SliverGrid.count(
						crossAxisCount: 2,
						mainAxisSpacing: 12,
						crossAxisSpacing: 12,
						children: [
							_DashCard(icon: Icons.forum, title: 'Posts', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedScreen()))),
							const _DashCard(icon: Icons.local_hospital, title: 'Treatments'),
							const _DashCard(icon: Icons.healing, title: 'Bleeds'),
							const _DashCard(icon: Icons.checklist, title: 'Checklists'),
						],
					),
				),
			],
		);
	}
}

class _DashCard extends StatelessWidget {
	const _DashCard({required this.icon, required this.title, this.onTap});
	final IconData icon;
	final String title;
	final VoidCallback? onTap;
	@override
	Widget build(BuildContext context) {
		final cs = Theme.of(context).colorScheme;
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(16),
			child: Ink(
				decoration: BoxDecoration(
					color: cs.surfaceContainerHighest,
					borderRadius: BorderRadius.circular(16),
					border: Border.all(color: cs.outlineVariant),
				),
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Icon(icon, color: cs.primary),
						const Spacer(),
						Text(title, style: Theme.of(context).textTheme.bodyLarge),
					],
				),
			),
		);
	}
}