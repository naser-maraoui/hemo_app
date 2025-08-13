import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShellScreen extends StatefulWidget {
	const ShellScreen({super.key});
	@override
	State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
	int index = 0;

	@override
	Widget build(BuildContext context) {
		final List<Widget> pages = [
			const _DashboardTab(),
			const _EducationTab(),
			const _ChatTab(),
			const _SettingsTab(),
		];
		return Scaffold(
			body: AnimatedSwitcher(
				duration: const Duration(milliseconds: 250),
				child: pages[index],
			),
			bottomNavigationBar: NavigationBar(
				selectedIndex: index,
				onDestinationSelected: (i) => setState(() => index = i),
				destinations: [
					NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: 'dashboard'.tr()),
					NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: 'education'.tr()),
					NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), selectedIcon: const Icon(Icons.chat_bubble), label: 'chat'.tr()),
					NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: 'settings'.tr()),
				],
			),
		);
	}
}

class _DashboardTab extends StatelessWidget {
	const _DashboardTab();
	@override
	Widget build(BuildContext context) {
		return Center(child: Text('dashboard'.tr()));
	}
}

class _EducationTab extends StatelessWidget {
	const _EducationTab();
	@override
	Widget build(BuildContext context) {
		return Center(child: Text('education'.tr()));
	}
}

class _ChatTab extends StatelessWidget {
	const _ChatTab();
	@override
	Widget build(BuildContext context) {
		return Center(child: Text('chat'.tr()));
	}
}

class _SettingsTab extends StatelessWidget {
	const _SettingsTab();
	@override
	Widget build(BuildContext context) {
		return const SizedBox.shrink();
	}
}