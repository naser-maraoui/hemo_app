import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

class PatientInfoScreen extends StatefulWidget {
	const PatientInfoScreen({super.key});
	@override
	State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
	final TextEditingController fullName = TextEditingController();
	final TextEditingController weight = TextEditingController();
	DateTime? birthdate;
	String hemoType = 'A';
	String severity = 'mild';
	bool saving = false;
	String? error;
	File? avatarFile;
	String? avatarUrl;

	Future<void> _pickAvatar() async {
		final ImagePicker picker = ImagePicker();
		final XFile? x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
		if (x != null) setState(() => avatarFile = File(x.path));
	}

	Future<void> _pickDate() async {
		final now = DateTime.now();
		final DateTime? picked = await showDatePicker(
			context: context,
			initialDate: DateTime(now.year - 18, now.month, now.day),
			firstDate: DateTime(1900, 1, 1),
			lastDate: now,
		);
		if (picked != null) setState(() => birthdate = picked);
	}

	Future<void> _save() async {
		setState(() { saving = true; error = null; });
		try {
			if (!kSupabaseConfigured) {
				throw Exception('Supabase not configured');
			}
			final uid = Supabase.instance.client.auth.currentUser?.id;
			if (uid == null) throw Exception('Not signed in');
			if (avatarFile != null) {
				avatarUrl = await StorageService.uploadAvatar(uid, avatarFile!);
			}
			await Supabase.instance.client.from('profiles').update({
				'full_name': fullName.text.trim(),
				'birthdate': birthdate?.toIso8601String(),
				'hemophilia_type': hemoType,
				'severity': severity,
				'weight_kg': weight.text.isEmpty ? null : double.tryParse(weight.text),
				'avatar_url': avatarUrl,
			}).eq('user_id', uid);
			if (!mounted) return;
			Navigator.of(context).pop();
		} catch (e) {
			setState(() => error = e.toString());
		} finally {
			if (mounted) setState(() => saving = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final cs = Theme.of(context).colorScheme;
		return Scaffold(
			appBar: AppBar(title: Text(tr('patient'))),
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [cs.surfaceContainerHighest, cs.primary.withOpacity(0.06)],
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
				),
				child: Center(
					child: SingleChildScrollView(
						child: ConstrainedBox(
							constraints: const BoxConstraints(maxWidth: 520),
							child: Card(
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
								margin: const EdgeInsets.all(16),
								child: Padding(
									padding: const EdgeInsets.all(20),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											Text('Complete your profile', style: Theme.of(context).textTheme.titleLarge),
											const SizedBox(height: 12),
											Center(
												child: Stack(children: [
													CircleAvatar(radius: 44, backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null, child: avatarFile == null ? const Icon(Icons.person, size: 44) : null),
													Positioned(
														right: 0,
														bottom: 0,
														child: IconButton(onPressed: _pickAvatar, icon: const Icon(Icons.camera_alt))
													),
												]),
											),
											const SizedBox(height: 12),
											TextField(controller: fullName, decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), labelText: tr('full_name'))),
											const SizedBox(height: 12),
											InputDecorator(
												decoration: const InputDecoration(prefixIcon: Icon(Icons.cake_outlined), labelText: 'Birthdate'),
												child: InkWell(onTap: _pickDate, child: Padding(
													padding: const EdgeInsets.symmetric(vertical: 12),
													child: Text(birthdate == null ? 'Tap to select' : DateFormat.yMMMd().format(birthdate!)),
												)),
											),
											const SizedBox(height: 12),
											Text('Hemophilia type'),
											Wrap(spacing: 8, children: [
												ChoiceChip(label: const Text('A'), selected: hemoType == 'A', onSelected: (_) => setState(() => hemoType = 'A')),
												ChoiceChip(label: const Text('B'), selected: hemoType == 'B', onSelected: (_) => setState(() => hemoType = 'B')),
												ChoiceChip(label: const Text('other'), selected: hemoType == 'other', onSelected: (_) => setState(() => hemoType = 'other')),
											]),
											const SizedBox(height: 12),
											Text('Severity'),
											Wrap(spacing: 8, children: [
												ChoiceChip(label: const Text('mild'), selected: severity == 'mild', onSelected: (_) => setState(() => severity = 'mild')),
												ChoiceChip(label: const Text('moderate'), selected: severity == 'moderate', onSelected: (_) => setState(() => severity = 'moderate')),
												ChoiceChip(label: const Text('severe'), selected: severity == 'severe', onSelected: (_) => setState(() => severity = 'severe')),
											]),
											const SizedBox(height: 12),
											TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixIcon: Icon(Icons.monitor_weight_outlined), labelText: 'Weight (kg)')),
											const SizedBox(height: 16),
											if (error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
											FilledButton(onPressed: saving ? null : _save, child: saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(tr('save'))),
										],
									),
								),
							),
						),
					),
				),
			),
		);
	}
}