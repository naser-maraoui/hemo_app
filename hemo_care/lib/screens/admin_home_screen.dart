import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatelessWidget {
	const AdminHomeScreen({super.key});
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text('admin'.tr()), actions: [IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings))]),
			body: const Center(child: Text('Admin dashboard')),
		);
	}
}