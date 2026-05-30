import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../database/vault_database.dart';

class CloudSyncService {
  CloudSyncService({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
    Connectivity? connectivity,
    VaultDatabase? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _connectivity = connectivity ?? Connectivity(),
        _database = database ?? VaultDatabase();

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;
  final VaultDatabase _database;

  Future<bool> canSyncNow() async {
    final wifiOnly = (await _database.getSetting('wifi_only_sync')) != 'false';
    final connectivity = await _connectivity.checkConnectivity();
    if (!wifiOnly) return !connectivity.contains(ConnectivityResult.none);
    return connectivity.contains(ConnectivityResult.wifi) || connectivity.contains(ConnectivityResult.ethernet);
  }

  Future<void> uploadEncryptedVaultItems() async {
    final user = _auth.currentUser;
    if (user == null || !await canSyncNow()) return;
    final items = await _database.listVaultItems();

    for (final item in items) {
      final encryptedFile = File(item.encryptedPath);
      if (!await encryptedFile.exists()) continue;

      // Security-sensitive: upload encrypted .cpix blobs only. Never upload
      // raw media, master keys, database passphrases, or PIN material.
      final cloudPath = 'users/${user.uid}/vault/${item.id}.cpix';
      await _storage.ref(cloudPath).putFile(encryptedFile);
      await _firestore.collection('users').doc(user.uid).collection('vault_items').doc(item.id).set({
        'id': item.id,
        'type': item.type.name,
        'cloudPath': cloudPath,
        'originalName': item.originalName,
        'createdAt': item.createdAt.millisecondsSinceEpoch,
        'deletedAt': item.deletedAt?.millisecondsSinceEpoch,
        'mimeType': item.mimeType,
        'sizeBytes': item.sizeBytes,
      }, SetOptions(merge: true));
    }
  }

  Future<List<Map<String, dynamic>>> listRemoteRestoreCandidates() async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    final snapshot = await _firestore.collection('users').doc(user.uid).collection('vault_items').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
