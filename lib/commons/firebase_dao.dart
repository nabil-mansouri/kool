import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AbstractFirebaseDao<QUERY, ENTITY> {
  CollectionReference ref;
  AbstractFirebaseDao(String col) : ref = Firestore.instance.collection(col);
  AbstractFirebaseDao.fromRef(CollectionReference ref) {
    this.ref = ref;
  }
  AbstractFirebaseDao.fromParent(DocumentReference ref, String col) {
    this.ref = ref.collection(col);
  }
  //abstract
  ENTITY fromFirebase(Map<String, dynamic> json, {String id, QUERY query});
  Map<String, dynamic> toFirebase(ENTITY entity);
  Query toQuery(Query fQuery, QUERY query);
  //
  Future<ENTITY> fetchById(String id) async {
    var document = await this.ref.document(id).get();
    return fromFirebase(document.data, id: id);
  }

  Future<List<ENTITY>> fetch(QUERY query) async {
    Query fQuery = toQuery(this.ref, query);
    QuerySnapshot snapshots = await fQuery.getDocuments();
    List<ENTITY> entities = snapshots.documents
        .map((f) => fromFirebase(f.data, id: f.documentID, query: query))
        .toList();
    return entities;
  }

  Future<List<ENTITY>> createAll(List<ENTITY> entities,
      {bool forceId = false}) async {
    return Future.wait(entities.map(
        (f) => forceId ? create(f, forceId: (f as dynamic).id) : create(f)));
  }

  Future<ENTITY> create(ENTITY model, {String forceId}) async {
    final json = toFirebase(model);
    if (forceId != null) {
      await this.ref.document(forceId).setData(json);
      (model as dynamic).id = forceId;
    } else {
      final res = await this.ref.add(json);
      (model as dynamic).id = res.documentID;
    }
    return model;
  }

  Future<ENTITY> update(String id, ENTITY model) async {
    final json = toFirebase(model);
    await this.ref.document(id).setData(json);
    return model;
  }

  Future<void> deleteById(String id) {
    return this.ref.document(id).delete();
  }

  Future<void> delete(ENTITY e) {
    return this.ref.document((e as dynamic).id).delete();
  }

  Future<void> deleteAll(Iterable<ENTITY> all) {
    return Future.wait(
        all.map((f) => this.ref.document((f as dynamic).id).delete()));
  }
}
