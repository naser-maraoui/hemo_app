import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
	const DashboardTab({super.key});
	@override
	Widget build(BuildContext context) {
		final cs = Theme.of(context).colorScheme;
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
						children: const [
							_DashCard(icon: Icons.local_hospital, title: 'Treatments'),
							_DashCard(icon: Icons.healing, title: 'Bleeds'),
							_DashCard(icon: Icons.checklist, title: 'Checklists'),
							_DashCard(icon: Icons.schedule, title: 'Reminders'),
						],
					),
				),
			],
		);
	}
}

class _DashCard extends StatelessWidget {
	const _DashCard({required this.icon, required this.title});
	final IconData icon;
	final String title;
	@override
	Widget build(BuildContext context) {
		final cs = Theme.of(context).colorScheme;
		return Container(
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
		);
	}
}