import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../security/vault_key_store.dart';

final vaultKeyStoreProvider = Provider<VaultKeyStore>((ref) {
  return const VaultKeyStore();
});

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final keys = ref.watch(vaultKeyStoreProvider);
  final db = await AppDatabase.open(keyStore: keys);
  ref.onDispose(db.close);
  return db;
});
