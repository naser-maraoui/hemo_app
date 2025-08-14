import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatefulWidget {
	const OfflineBanner({super.key});

	@override
	State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
	late final Stream<List<ConnectivityResult>> _stream;
	List<ConnectivityResult> _status = const [ConnectivityResult.mobile];

	@override
	void initState() {
		super.initState();
		_stream = Connectivity().onConnectivityChanged;
		Connectivity().checkConnectivity().then((value) => setState(() => _status = value));
	}

	@override
	Widget build(BuildContext context) {
		return StreamBuilder<List<ConnectivityResult>>(
			stream: _stream,
			builder: (ctx, snap) {
				if (snap.hasData) _status = snap.data!;
				final bool isOffline = _status.length == 1 && _status.first == ConnectivityResult.none;
				return AnimatedContainer(
					duration: const Duration(milliseconds: 250),
					height: isOffline ? 28 : 0,
					color: Colors.orange,
					alignment: Alignment.center,
					child: isOffline ? Text('offline'.tr(), style: const TextStyle(color: Colors.black)) : const SizedBox.shrink(),
				);
			},
		);
	}
}