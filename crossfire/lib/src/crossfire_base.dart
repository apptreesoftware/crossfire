import 'dart:async';

import 'configuration.dart';

abstract class Firebase {
  Future init(FirebaseConfiguration config,
      {String bundleId, bool usePersistence});
  Future<bool> signIn(String token);
  Future<Null> signOut();
  Future<bool> isLoggedIn();
  Future<FirebaseCollection> getCollection(String path);
  Future<FirebaseDocumentReference> getDocument(String path);
  Future<FirebaseStorageRef> getStorage(String path);
  bool get isConnected;
  Stream<bool> get onConnectivityUpdated;
  Future<FirebaseBatch> batch();
}

abstract class FirebaseDocument {
  Map<String, dynamic> get data;
  String get documentID;
  bool get exists;
  FirebaseDocumentReference get ref;
}

abstract class FirebaseDocumentReference {
  Future<FirebaseDocument> get document;
  String get documentID;
  Future<Null> setData(Map<String, dynamic> data, {bool merge: false});
  Future<Null> update(Map<String, dynamic> data);
  Future<Null> delete();
  Stream<FirebaseDocument> get onSnapshot;
}

abstract class FirebaseCollection {
  Stream<Iterable<FirebaseDocument>> get documents;
  Stream<FirebaseQuerySnapshot> get query;
  Future<FirebaseDocumentReference> add(Map<String, dynamic> document);
  FirebaseDocumentReference document([String path]);
  FirebaseQuery where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  });
  FirebaseQuery orderBy(String field, {bool descending: false});
  FirebaseQuery startAfter({
    FirebaseDocument snapshot,
    List fieldValues,
  });
}

abstract class FirebaseQuerySnapshot {
  List<FirebaseDocument> get documents;
  List<FirebaseDocumentChange> get documentChanges;
}

abstract class FirebaseDocumentChange {
  int get oldIndex;
  int get newIndex;
  FireDocumentChangeType get type;
  FirebaseDocument get document;
}

abstract class FirebaseStorageRef {
  Future<String> get downloadUrl;
  Future<FirebaseStorageMetadata> get metadata;
  Future upload(dynamic file, String contentType);
  String get path;
}

abstract class FirebaseStorageMetadata {
  DateTime get lastModified;
  String get name;
  String get path;
  String get contentType;
  int get size;
}

abstract class FirebaseQuery {
  Stream<FirebaseQuerySnapshot> get snapshots;
  Future<FirebaseQuerySnapshot> get documents;
  FirebaseQuery where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  });
  FirebaseQuery orderBy(String field, {bool descending: false});
  FirebaseQuery limit(int length);
  FirebaseQuery startAfter({
    FirebaseDocument snapshot,
    List fieldValues,
  });
}

enum FireDocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

abstract class FirebaseBatch {
  Future<void> commit();
  FirebaseBatch delete(FirebaseDocumentReference documentRef);
  FirebaseBatch setData(
    FirebaseDocumentReference documentRef,
    Map<String, dynamic> data, {
    bool merge: false,
  });
  FirebaseBatch updateData(
    FirebaseDocumentReference documentRef, {
    Map<String, dynamic> data,
    List fieldsAndValues,
  });
}
