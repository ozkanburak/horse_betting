import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';

String _authStatus = 'Unknown';

Future<void> initPlugin(context) async {
  final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;
  _authStatus = '$status';
  // If the system can show an authorization request dialog
  if (status == TrackingStatus.notDetermined) {
    // Show a custom explainer dialog before the system dialog
    await showCustomTrackingDialog(context);
    // Wait for dialog popping animation
    await Future.delayed(const Duration(milliseconds: 200));
    // Request system's tracking authorization dialog
    final TrackingStatus status =
        await AppTrackingTransparency.requestTrackingAuthorization();
    _authStatus = '$status';
  }

  final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  print("UUID: $uuid");
}

Future<void> showCustomTrackingDialog(BuildContext context) async =>
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dear User'),
        content: const Text(
            'We care about your privacy and data security. We keep this app free by displaying ads.'
            'Our partners collect data and use a unique identifier found on your device to serve ads'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuation'),
          ),
        ],
      ),
    );