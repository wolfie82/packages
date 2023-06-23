import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

class GoogleMapWrapper extends StatefulWidget {
  final Function(GoogleMapController) onMapCreated;

  GoogleMapWrapper({required this.onMapCreated});

  @override
  _GoogleMapWrapperState createState() => _GoogleMapWrapperState();
}

class _GoogleMapWrapperState extends State<GoogleMapWrapper> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        _controller = controller;
        widget.onMapCreated(controller);
      },
      initialCameraPosition:
          CameraPosition(target: LatLng(0.0, 0.0), zoom: 10.0),
    );
  }
}

void main() {
  testWidgets('Subscriptions are cleaned up on dispose',
      (WidgetTester tester) async {
    final fakePlatform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = fakePlatform;

    final controllerCompleter = Completer<GoogleMapController>();

    await tester.pumpWidget(
      MaterialApp(
        home: GoogleMapWrapper(
          onMapCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Dispose the widget.
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    // Verify that all subscriptions are canceled.
    expect(fakePlatform.subscriptions.every((sub) => sub.isCanceled), true);
  });
}
