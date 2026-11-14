import 'package:permission_handler/permission_handler.dart';

/// Driver permissions for dispatch, navigation and driver communication.
Future<void> requestBakeTaxiPermissions() async {
  final runtimePermissions = <Permission>[
    Permission.notification,
    Permission.locationWhenInUse,
    Permission.camera,
    Permission.photos,
    Permission.audio,
    Permission.microphone,
    Permission.phone,
    Permission.contacts,
    Permission.activityRecognition,
    Permission.locationAlways,
  ];

  for (final permission in runtimePermissions) {
    try {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited && !status.isPermanentlyDenied) {
        await permission.request();
      }
    } catch (_) {
      // A denied permission must not prevent the driver app from opening.
    }
  }

  try {
    final overlay = await Permission.systemAlertWindow.status;
    if (!overlay.isGranted && !overlay.isPermanentlyDenied) {
      await Permission.systemAlertWindow.request();
    }
  } catch (_) {
    // Android opens a dedicated system settings screen for overlay access.
  }
}
