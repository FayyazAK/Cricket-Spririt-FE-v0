import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  /// Requests all permissions the app needs up-front.
  /// Safe no-op on web/unsupported platforms.
  static Future<void> requestStartupPermissions() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    // Request in one shot (the OS may still show dialogs sequentially).
    // Note: On Android 13+, "Storage" is not used for media picking; Photos/Videos are.
    final permissions = <Permission>[
      Permission.camera,
      Permission.photos,
      Permission.videos,
      Permission.locationWhenInUse,
      // Storage is needed on older Android for file/media access.
      if (Platform.isAndroid) Permission.storage,
    ];

    await permissions.request();
  }
}

