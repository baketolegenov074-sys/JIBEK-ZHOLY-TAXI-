import 'package:permission_handler/permission_handler.dart';

/// Owner app asks only for notifications and image access.
Future<void> requestBakeTaxiPermissions() async {
  for (final permission in [Permission.notification, Permission.photos]) {
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
