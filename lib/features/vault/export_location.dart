import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Saves [bytes] to a folder the user can open in Files / Finder.
///
/// On Android, skips the app-private `Android/data/.../Download` folder
/// (what [getDownloadsDirectory] returns) and uses the public Downloads
/// path when possible, otherwise a system save dialog (Downloads / Documents).
///
/// Returns `null` if the user cancels the save dialog.
Future<File?> saveToUserAccessibleLocation({
  required String fileName,
  required List<int> bytes,
  String dialogTitle = 'Save file',
}) async {
  final data = Uint8List.fromList(bytes);

  final direct = await _tryWritePublicDownloads(fileName, data);
  if (direct != null) {
    debugPrint('Kash export saved: ${direct.path}');
    return direct;
  }

  // Lets the user pick Downloads, Documents, Drive, etc. (visible outside the app).
  final picked = await FilePicker.platform.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    bytes: data,
  );
  if (picked == null || picked.isEmpty) return null;

  // Ignore app-sandbox paths if the picker somehow returned one.
  if (_isAppPrivatePath(picked)) {
    debugPrint('Kash export rejected app-private path: $picked');
    return null;
  }

  final file = File(picked);
  if (!await file.exists() || await file.length() == 0) {
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data, flush: true);
  }
  debugPrint('Kash export saved: ${file.path}');
  return file;
}

/// Public Downloads only — never [getDownloadsDirectory] on Android
/// (that is `/Android/data/<package>/files/Download`, not user-visible).
Future<File?> _tryWritePublicDownloads(String fileName, Uint8List data) async {
  final candidates = <Directory>[];

  if (Platform.isAndroid) {
    candidates.add(Directory('/storage/emulated/0/Download'));
    candidates.add(Directory('/storage/emulated/0/Downloads'));
  } else {
    // Desktop / platforms where getDownloadsDirectory is the real Downloads folder.
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null && !_isAppPrivatePath(downloads.path)) {
        candidates.add(downloads);
      }
    } catch (_) {}
  }

  for (final dir in candidates) {
    try {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(data, flush: true);
      if (await file.exists() && await file.length() > 0) {
        if (_isAppPrivatePath(file.path)) return null;
        return file;
      }
    } catch (_) {
      // Scoped storage / permission — fall through to the save dialog.
    }
  }
  return null;
}

bool _isAppPrivatePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('/Android/data/') ||
      normalized.contains('/data/user/') ||
      normalized.contains('/app_flutter/') ||
      normalized.contains('/containers/Data/Application/');
}
