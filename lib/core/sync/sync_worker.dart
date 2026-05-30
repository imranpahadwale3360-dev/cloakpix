import 'package:workmanager/workmanager.dart';

import 'cloud_sync_service.dart';

const cloakPixSyncTask = 'cloakpix.encrypted.cloud.sync';

@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == cloakPixSyncTask) {
      await CloudSyncService().uploadEncryptedVaultItems();
    }
    return true;
  });
}

class SyncWorker {
  Future<void> registerPeriodicSync() {
    return Workmanager().registerPeriodicTask(
      cloakPixSyncTask,
      cloakPixSyncTask,
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
