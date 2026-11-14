import 'package:permission_handler/permission_handler.dart';

/// Requests the permissions used by Bake Taxi features one at a time.
/// Android special access (background location and overlay) may require
/// the user to complete a separate system Settings screen.
Future<void> requestBakeTaxiPermissions() async {
  final runtimePermissions = <Permission>[
    Permission.notification,
    Permission.locationWhenInUse,
    Permission.camera,
    Permission.photos,
    Permission.audio,
    Permission.storage,
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
      // A denied optional permission must not prevent the app from opening.
    }
  }

  try {
    final overlay = await Permission.systemAlertWindow.status;
    if (!overlay.isGranted && !overlay.isPermanentlyDenied) {
      await Permission.systemAlertWindow.request();
    }
  } catch (_) {
    // Overlay access is special app access and can be enabled later in Settings.
  }
}
