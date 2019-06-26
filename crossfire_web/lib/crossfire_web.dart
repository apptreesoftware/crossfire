library crossfire_web;

import 'dart:async';

import 'package:crossfire/crossfire.dart';
import 'package:jsifier/jsifier.dart' as jsifier;
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart';

class FirebaseWeb implements Firebase {
  final StreamController<bool> _connectionChangeSink;
  fb.Auth auth;
  Firestore _store;
  fb.Storage _storage;

  FirebaseWeb() : _connectionChangeSink = new StreamController.broadcast();

  @override
  Future init(FirebaseConfiguration config,
      {String bundleId, bool usePersistence}) async {
    var app;
    try {
      app = fb.app(config.projectId);
    } catch (e) {}
    if (app == null) {
      app = fb.initializeApp(
          apiKey: config.apiKey,
          authDomain: config.authDomain,
          databaseURL: config.databaseUrl,
          projectId: config.projectId,
          storageBucket: config.storageBucket,
          messagingSenderId: config.messageSenderId,
          name: config.projectId);
    }
    auth = fb.auth(app);
    _store = fb.firestore(app);
    if (usePersistence != null && usePersistence) {
      try {
        _store.enablePersistence();
      } catch (e) {
        // Support re-initializing with a different app. Enabling persistence
        // can throw an error if it has already been enabled once on the page.
      }
    }
    _storage = fb.storage(app);
  }

  @override
  Future<FirebaseCollection> getCollection(String path) async {
    var collection = await _store.collection(path);
    return new BrowserFirebaseCollection(collection);
  }

  @override
  Future<FirebaseDocumentReference> getDocument(String path) async {
    var ref = _store.doc(path);
    return new BrowserFirebaseDocReference(ref);
  }

  @override
  Future<FirebaseStorageRef> getStorage(String path) async {
    var ref = _storage.ref(path);
    return new BrowserFirebaseStorageRef(ref);
  }

  Future<bool> isLoggedIn() {
    return new Future.value(auth.currentUser != null);
  }

  Future<bool> signIn(String token) async {
    var user = await auth.signInWithCustomToken(token);
    return user != null;
  }

  Future<Null> signOut() async {
    await auth.signOut();
  }

  @override
  bool get isConnected => true;

  @override
  Stream<bool> get onConnectivityUpdated => _connectionChangeSink.stream;

  @override
  Future<FirebaseBatch> batch() async {
    var b = _store.batch();
    return BrowserFirebaseBatch(b);
  }
}

class BrowserFirebaseQuerySnapshot implements FirebaseQuerySnapshot {
  final QuerySnapshot _snapshot;

  BrowserFirebaseQuerySnapshot(this._snapshot);

  @override
  List<FirebaseDocumentChange> get documentChanges => _snapshot
      .docChanges()
      .map((c) => new BrowserFirebaseDocumentChange(c))
      .toList();

  @override
  List<FirebaseDocument> get documents =>
      _snapshot.docs.map((s) => new BrowserDocumentSnapshot(s)).toList();
}

class BrowserFirebaseDocumentChange implements FirebaseDocumentChange {
  final DocumentChange _change;

  BrowserFirebaseDocumentChange(this._change);

  FirebaseDocument get document => new BrowserDocumentSnapshot(_change.doc);

  int get newIndex => _change.newIndex;
  int get oldIndex => _change.oldIndex;

  @override
  FireDocumentChangeType get type {
    switch (_change.type) {
      case "added":
        return FireDocumentChangeType.added;
      case "modified":
        return FireDocumentChangeType.modified;
      case "removed":
        return FireDocumentChangeType.removed;
    }
    return FireDocumentChangeType.modified;
  }
}

class BrowserFirebaseCollection implements FirebaseCollection {
  final CollectionReference _collection;

  BrowserFirebaseCollection(this._collection);

  Future<FirebaseDocumentReference> add(Map<String, dynamic> document) async {
    var docReference = await _collection.add(document);
    return new BrowserFirebaseDocReference(docReference);
  }

  FirebaseDocumentReference document([String path]) {
    var docReference = _collection.doc(path);
    return new BrowserFirebaseDocReference(docReference);
  }

  Stream<Iterable<FirebaseDocument>> get documents =>
      _collection.onSnapshot.map((q) =>
          q.docs.map((snapshot) => new BrowserDocumentSnapshot(snapshot)));

  Stream<BrowserFirebaseQuerySnapshot> get query =>
      _collection.onSnapshot.map((q) => new BrowserFirebaseQuerySnapshot(q));

  @override
  FirebaseQuery orderBy(String field, {bool descending: false}) {
    return new BrowserFirebaseQuery(
        _collection.orderBy(field, descending ? "desc" : "asc"));
  }

  FirebaseQuery where(String field,
      {dynamic isEqualTo,
      dynamic isLessThan,
      dynamic isLessThanOrEqualTo,
      dynamic isGreaterThan,
      dynamic isGreaterThanOrEqualTo,
      bool isNull}) {
    var op = "";
    var value = null;
    if (isEqualTo != null) {
      op = "==";
      value = isEqualTo;
    } else if (isLessThan != null) {
      op = "<";
      value = isLessThan;
    } else if (isLessThanOrEqualTo != null) {
      op = "<=";
      value = isLessThanOrEqualTo;
    } else if (isGreaterThan != null) {
      op = ">";
      value = isGreaterThan;
    } else if (isGreaterThanOrEqualTo != null) {
      op = ">=";
      value = isGreaterThanOrEqualTo;
    }
    var q = _collection.where(field, op, value);
    return new BrowserFirebaseQuery(q);
  }

  @override
  FirebaseQuery startAfter({
    FirebaseDocument snapshot,
    List fieldValues,
  }) {
    DocumentSnapshot snap;

    if (snapshot != null) {
      final doc = snapshot as BrowserDocumentSnapshot;
      snap = doc._snapshot;
    }

    final q = _collection.startAfter(
      snapshot: snap,
      fieldValues: fieldValues,
    );
    return BrowserFirebaseQuery(q);
  }
}

class BrowserDocumentSnapshot implements FirebaseDocument {
  final DocumentSnapshot _snapshot;

  BrowserDocumentSnapshot(this._snapshot);

  Map<String, dynamic> get data {
    var snapshotData = _snapshot.data();
    if (snapshotData is Map) {
      return snapshotData;
    }
    var jsifiedData = jsifier.Jsifier.decode(snapshotData);
    return jsifiedData;
  }

  String get documentID => _snapshot.id;

  bool get exists => _snapshot.exists;

  FirebaseDocumentReference get ref =>
      new BrowserFirebaseDocReference(_snapshot.ref);
}

class BrowserFirebaseDocReference implements FirebaseDocumentReference {
  final DocumentReference _ref;

  BrowserFirebaseDocReference(this._ref);

  Future<Null> delete() async {
    await _ref.delete();
  }

  Future<FirebaseDocument> get document async {
    var doc = await _ref.get();
    return new BrowserDocumentSnapshot(doc);
  }

  String get documentID => _ref.id;

  Future<Null> setData(Map<String, dynamic> data, {bool merge: false}) async {
    await _ref.set(data, new SetOptions(merge: merge));
  }

  Future<Null> update(Map<String, dynamic> data) async =>
      await _ref.update(data: data);

  Stream<BrowserDocumentSnapshot> get onSnapshot {
    return _ref.onSnapshot.map((d) => new BrowserDocumentSnapshot(d));
  }
}

class BrowserFirebaseStorageRef implements FirebaseStorageRef {
  final fb.StorageReference _ref;

  BrowserFirebaseStorageRef(this._ref);

  Future<String> get downloadUrl async =>
      (await this._ref.getDownloadURL()).toString();
  Future<FirebaseStorageMetadata> get metadata async {
    var metaData = await _ref.getMetadata();
    return new BrowserFirebaseStorageMetadata(metaData);
  }

  Future upload(dynamic blob, String contentType) {
    var uploadTask =
        _ref.put(blob, new fb.UploadMetadata(contentType: contentType));
    return uploadTask.future;
  }

  String get path => _ref.fullPath;
}

class BrowserFirebaseStorageMetadata implements FirebaseStorageMetadata {
  final fb.FullMetadata _metadata;

  BrowserFirebaseStorageMetadata(this._metadata);

  DateTime get lastModified => new DateTime.fromMillisecondsSinceEpoch(
      _metadata.updated.millisecondsSinceEpoch);
  String get name => _metadata.name;
  String get path => _metadata.fullPath;
  String get contentType => _metadata.contentType;
  int get size => _metadata.size;
}

class BrowserFirebaseQuery extends FirebaseQuery {
  final Query _ref;

  BrowserFirebaseQuery(this._ref);

  @override
  FirebaseQuery limit(int length) {
    return new BrowserFirebaseQuery(_ref.limit(length));
  }

  @override
  FirebaseQuery orderBy(String field, {bool descending: false}) {
    return new BrowserFirebaseQuery(
        _ref.orderBy(field, descending ? "desc" : "asc"));
  }

  Stream<FirebaseQuerySnapshot> get snapshots =>
      _ref.onSnapshot.map((qs) => new BrowserFirebaseQuerySnapshot(qs));

  Future<FirebaseQuerySnapshot> get documents async {
    var snapshot = await _ref.get();
    return new BrowserFirebaseQuerySnapshot(snapshot);
  }

  FirebaseQuery where(String field,
      {dynamic isEqualTo,
      dynamic isLessThan,
      dynamic isLessThanOrEqualTo,
      dynamic isGreaterThan,
      dynamic isGreaterThanOrEqualTo,
      bool isNull}) {
    var op = "";
    var value = null;
    if (isEqualTo != null) {
      op = "==";
      value = isEqualTo;
    } else if (isLessThan != null) {
      op = "<";
      value = isLessThan;
    } else if (isLessThanOrEqualTo != null) {
      op = "<=";
      value = isLessThanOrEqualTo;
    } else if (isGreaterThan != null) {
      op = ">";
      value = isGreaterThan;
    } else if (isGreaterThanOrEqualTo != null) {
      op = ">=";
      value = isGreaterThanOrEqualTo;
    }
    if (op.isEmpty) {
      return this;
    }
    var q = _ref.where(field, op, value);
    return new BrowserFirebaseQuery(q);
  }

  @override
  FirebaseQuery startAfter({
    FirebaseDocument snapshot,
    List fieldValues,
  }) {
    DocumentSnapshot snap;
    if (snapshot != null) {
      final doc = snapshot as BrowserDocumentSnapshot;
      snap = doc._snapshot;
    }

    final q = _ref.startAfter(
      snapshot: snap,
      fieldValues: fieldValues,
    );
    return BrowserFirebaseQuery(q);
  }
}

class BrowserFirebaseBatch implements FirebaseBatch {
  final WriteBatch _batch;

  BrowserFirebaseBatch(this._batch);

  @override
  Future<void> commit() => _batch.commit();

  @override
  FirebaseBatch delete(FirebaseDocumentReference documentRef) {
    final doc = documentRef as BrowserFirebaseDocReference;
    final b = _batch.delete(doc._ref);
    return BrowserFirebaseBatch(b);
  }

  @override
  FirebaseBatch setData(
    FirebaseDocumentReference documentRef,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    final doc = documentRef as BrowserFirebaseDocReference;
    final b = _batch.set(doc._ref, data, SetOptions(merge: merge));
    return BrowserFirebaseBatch(b);
  }

  @override
  FirebaseBatch updateData(
    FirebaseDocumentReference documentRef, {
    Map<String, dynamic> data,
    List fieldsAndValues,
  }) {
    final doc = documentRef as BrowserFirebaseDocReference;
    final b =
        _batch.update(doc._ref, data: data, fieldsAndValues: fieldsAndValues);
    return BrowserFirebaseBatch(b);
  }
}
