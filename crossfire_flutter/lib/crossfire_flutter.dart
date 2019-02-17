library crossfire_flutter;

import 'dart:async';
import 'dart:io';

import 'package:crossfire/crossfire.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart' hide Query;

class FlutterFirebase implements Firebase {
  final StreamController<bool> _connectionChangedSink;
  bool _connected;
  Firestore _firestore;
  FirebaseAuth auth;
  FirebaseStorage _storage;

  FlutterFirebase()
      : _connected = false,
        _connectionChangedSink = new StreamController.broadcast();

  // TODO: wrap user with a wrapper class and add to super class
  Future<FirebaseUser> get currentUser async => await auth.currentUser();

  @override
  Future init(FirebaseConfiguration config,
      {String bundleId, bool usePersistence}) async {
    var platform = defaultTargetPlatform;
    var googleApiKey = platform == TargetPlatform.android
        ? config.androidGoogleAppId
        : config.iosGoogleAppId;
    var app = await FirebaseApp.appNamed(config.projectId);
    if (app == null) {
      app = await FirebaseApp.configure(
        name: config.projectId,
        options: new FirebaseOptions(
          googleAppID: googleApiKey,
          gcmSenderID: config.messageSenderId,
          projectID: config.projectId,
          databaseURL: config.databaseUrl,
          storageBucket: config.storageBucket,
          apiKey: config.apiKey,
          bundleID: bundleId,
        ),
      );
      _connected = true;
    }
    _firestore = new Firestore(app: app);
    if (usePersistence != null) {
      _firestore.enablePersistence(usePersistence);
    }
    auth = new FirebaseAuth(app: app);
    _storage = new FirebaseStorage(app: app);
    _listenForConnectivityChanges();
  }

  @override
  Future<FirebaseCollection> getCollection(String path) async {
    var c = _firestore.collection(path);
    return new FlutterFirebaseCollection(c);
  }

  @override
  Future<FirebaseDocumentReference> getDocument(String path) async {
    var ref = _firestore.document(path);
    return new FlutterFirebaseDocReference(ref);
  }

  @override
  Future<FirebaseStorageRef> getStorage(String path) async {
    var ref = _storage.ref().child(path);
    return new FlutterFirebaseStorageRef(ref);
  }

  @override
  Future<bool> signIn(String token) async {
    var user = await auth.signInWithCustomToken(token: token);
    return user != null;
  }

  @override
  Future<Null> signOut() async {
    await auth.signOut();
  }

  @override
  Future<bool> isLoggedIn() async => await auth.currentUser() != null;

  void _listenForConnectivityChanges() {
    FirebaseDatabase.instance
        .reference()
        .child(".info/connected")
        .onValue
        .listen((e) {
      if (e.snapshot.value is int) {
        _connected = e.snapshot.value == 1;
      } else {
        _connected = e.snapshot.value;
      }
      _connectionChangedSink.add(_connected);
    });
  }

  @override
  bool get isConnected => _connected;

  @override
  Stream<bool> get onConnectivityUpdated => _connectionChangedSink.stream;

  @override
  Future<FirebaseBatch> batch() async {
    final b = _firestore.batch();
    return FlutterFirebaseBatch(b);
  }
}

class FlutterFirebaseDocReference implements FirebaseDocumentReference {
  final DocumentReference ref;

  FlutterFirebaseDocReference(this.ref);

  Future<FirebaseDocument> get document async =>
      new FlutterFirebaseDoc(await ref.get());

  Future<Null> setData(Map<String, dynamic> data, {bool merge: false}) async =>
      await this.ref.setData(data, merge: merge);

  Future<Null> update(Map<String, dynamic> data) async =>
      await ref.updateData(data);

  Future<Null> delete() async {
    await this.ref.delete();
  }

  String get documentID => this.ref.documentID;

  @override
  Stream<FirebaseDocument> get onSnapshot {
    return ref.snapshots().map((s) => new FlutterFirebaseDoc(s));
  }
}

class FlutterFirebaseDoc implements FirebaseDocument {
  final DocumentSnapshot snapshot;
  FlutterFirebaseDoc(this.snapshot);

  Map<String, dynamic> get data => this.snapshot.data;

  String get documentID => this.snapshot.documentID;

  bool get exists => snapshot.exists;

  FirebaseDocumentReference get ref =>
      new FlutterFirebaseDocReference(snapshot.reference);
}

class FlutterFirebaseCollection implements FirebaseCollection {
  final CollectionReference collection;

  FlutterFirebaseCollection(this.collection);

  Future<FirebaseDocumentReference> add(Map<String, dynamic> document) async {
    var ref = await this.collection.add(document);
    return new FlutterFirebaseDocReference(ref);
  }

  FirebaseDocumentReference document([String path]) {
    return new FlutterFirebaseDocReference(collection.document(path));
  }

  Stream<Iterable<FirebaseDocument>> get documents =>
      collection.snapshots().map((q) =>
          q.documents.map((snapshot) => new FlutterFirebaseDoc(snapshot)));

  Stream<FlutterFirebaseQuerySnapshot> get query =>
      collection.snapshots().map((q) => new FlutterFirebaseQuerySnapshot(q));

  @override
  FirebaseQuery where(String field,
      {dynamic isEqualTo,
      dynamic isLessThan,
      dynamic isLessThanOrEqualTo,
      dynamic isGreaterThan,
      dynamic isGreaterThanOrEqualTo,
      bool isNull}) {
    var q = collection.where(field,
        isEqualTo: isEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull);
    return new FlutterFirebaseQuery(q);
  }

  @override
  FirebaseQuery orderBy(String field, {bool descending: false}) {
    var q = collection.orderBy(field, descending: descending);
    return new FlutterFirebaseQuery(q);
  }
}

class FlutterFirebaseQuery implements FirebaseQuery {
  final Query _ref;

  FlutterFirebaseQuery(this._ref);

  FirebaseQuery limit(int length) {
    return new FlutterFirebaseQuery(_ref.limit(length));
  }

  FirebaseQuery orderBy(String field, {bool descending: false}) {
    return new FlutterFirebaseQuery(
        _ref.orderBy(field, descending: descending));
  }

  @override
  FirebaseQuery where(String field,
      {dynamic isEqualTo,
      dynamic isLessThan,
      dynamic isLessThanOrEqualTo,
      dynamic isGreaterThan,
      dynamic isGreaterThanOrEqualTo,
      bool isNull}) {
    var q = _ref.where(field,
        isEqualTo: isEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull);
    return new FlutterFirebaseQuery(q);
  }

  Stream<FirebaseQuerySnapshot> get snapshots =>
      _ref.snapshots().map((q) => new FlutterFirebaseQuerySnapshot(q));

  Future<FirebaseQuerySnapshot> get documents async {
    var snapshot = await _ref.getDocuments();
    return new FlutterFirebaseQuerySnapshot(snapshot);
  }
}

class FlutterFirebaseQuerySnapshot implements FirebaseQuerySnapshot {
  final QuerySnapshot _snapshot;

  FlutterFirebaseQuerySnapshot(this._snapshot);

  @override
  List<FirebaseDocumentChange> get documentChanges => _snapshot.documentChanges
      .map((c) => new FlutterFirebaseDocumentChange(c))
      .toList();

  @override
  List<FirebaseDocument> get documents =>
      _snapshot.documents.map((s) => new FlutterFirebaseDoc(s)).toList();
}

class FlutterFirebaseDocumentChange implements FirebaseDocumentChange {
  final DocumentChange _change;

  FlutterFirebaseDocumentChange(this._change);
  FirebaseDocument get document => new FlutterFirebaseDoc(_change.document);
  int get newIndex => _change.newIndex;
  int get oldIndex => _change.oldIndex;

  FireDocumentChangeType get type {
    switch (_change.type) {
      case DocumentChangeType.added:
        return FireDocumentChangeType.added;
      case DocumentChangeType.modified:
        return FireDocumentChangeType.modified;
      case DocumentChangeType.removed:
        return FireDocumentChangeType.removed;
    }
    return FireDocumentChangeType.modified;
  }
}

class FlutterFirebaseStorageRef implements FirebaseStorageRef {
  final StorageReference _ref;

  FlutterFirebaseStorageRef(this._ref);

  Future<String> get downloadUrl async => await this._ref.getDownloadURL();
  Future<FirebaseStorageMetadata> get metadata async {
    var metaData = await _ref.getMetadata();
    return new FlutterStorageMetadata(metaData);
  }

  Future upload(dynamic file, String contentType) {
    var uploadTask = _ref.putFile(
        file as File, new StorageMetadata(contentType: contentType));
    return uploadTask.future;
  }

  String get path => _ref.path;
}

class FlutterStorageMetadata implements FirebaseStorageMetadata {
  final StorageMetadata _metadata;

  FlutterStorageMetadata(this._metadata);

  DateTime get lastModified =>
      new DateTime.fromMillisecondsSinceEpoch(_metadata.updatedTimeMillis);
  String get name => _metadata.name;
  String get path => _metadata.path;
  String get contentType => _metadata.contentType;
  int get size => _metadata.sizeBytes;
}

class FlutterFirebaseBatch implements FirebaseBatch {
  final WriteBatch _batch;

  FlutterFirebaseBatch(this._batch);

  @override
  Future<void> commit() => _batch.commit();

  @override
  FirebaseBatch delete(FirebaseDocumentReference documentRef) {
    final doc = documentRef as FlutterFirebaseDocReference;
    _batch.delete(doc.ref);
    return this;
  }

  @override
  FirebaseBatch setData(
    FirebaseDocumentReference documentRef,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    final doc = documentRef as FlutterFirebaseDocReference;
    _batch.setData(doc.ref, data, merge: merge);
    return this;
  }

  @override
  FirebaseBatch updateData(
    FirebaseDocumentReference documentRef, {
    Map<String, dynamic> data,
    List fieldsAndValues,
  }) {
    final doc = documentRef as FlutterFirebaseDocReference;
    _batch.updateData(doc.ref, data);
    return this;
  }
}