import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
	const OnboardingScreen({super.key});

	Future<void> _complete(BuildContext context) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool('seen_onboarding', true);
		if (!context.mounted) return;
		context.go('/signin');
	}

	@override
	Widget build(BuildContext context) {
		final ColorScheme cs = Theme.of(context).colorScheme;
		return Scaffold(
			body: SafeArea(
				child: Column(
					children: [
						Expanded(
							child: Container(
								decoration: BoxDecoration(
									gradient: LinearGradient(
										colors: [cs.primaryContainer, cs.primary.withOpacity(0.8)],
										begin: Alignment.topLeft,
										end: Alignment.bottomRight,
									),
									borderRadius: const BorderRadius.only(
										topLeft: Radius.circular(24),
										topRight: Radius.circular(24),
									),
								),
								child: Center(
									child: Column(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											Icon(Icons.health_and_safety, size: 96, color: cs.onPrimaryContainer),
											const SizedBox(height: 16),
											Text('onboarding_title'.tr(), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.onPrimaryContainer), textAlign: TextAlign.center),
											const SizedBox(height: 8),
											Padding(
												padding: const EdgeInsets.symmetric(horizontal: 24),
												child: Text('onboarding_desc'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.9)), textAlign: TextAlign.center),
											),
										],
									),
								),
							),
						),
						Padding(
							padding: const EdgeInsets.all(24),
							child: SizedBox(
								width: double.infinity,
								child: FilledButton.tonal(
									onPressed: () => _complete(context),
									child: Text('get_started'.tr()),
								),
							),
						),
					],
				),
			),
		);
	}
}