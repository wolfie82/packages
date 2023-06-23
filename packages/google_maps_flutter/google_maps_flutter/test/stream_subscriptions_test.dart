import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

void main() {
  testWidgets('Subscriptions are cleaned up on dispose',
      (WidgetTester tester) async {
    final fakePlatform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = fakePlatform;

    final controllerCompleter = Completer<GoogleMapController>();

    await tester.pumpWidget(
      MaterialApp(
        home: GoogleMap(
          onMapCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialCameraPosition:
              CameraPosition(target: LatLng(0.0, 0.0), zoom: 10.0),
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
