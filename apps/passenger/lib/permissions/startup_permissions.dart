import 'package:permission_handler/permission_handler.dart';

/// Passenger asks only for foreground location and notifications.
Future<void> requestBakeTaxiPermissions() async {
  for (final permission in [Permission.locationWhenInUse, Permission.notification]) {
    try {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited && !status.isPermanentlyDenied) {
        await permission.request();
      }
    } catch (_) {
      // Permission can be granted later in Android settings.
    }
  }
}
