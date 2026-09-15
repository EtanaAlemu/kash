import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import 'app_lock_service.dart';

final appLockServiceProvider = FutureProvider<AppLockService>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final keys = ref.watch(vaultKeyStoreProvider);
  final service = AppLockService(keys: keys, db: db);
  await service.restoreLockoutState();
  return service;
});
