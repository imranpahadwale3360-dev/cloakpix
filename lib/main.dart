import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/sync/sync_worker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stackTrace));
  }
  await Workmanager().initialize(syncCallbackDispatcher, isInDebugMode: false);
  runApp(const CloakPixApp());
}
