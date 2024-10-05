import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum StartAtStrategy { Back, Front }

abstract class _StartAtStrategy {
  Query onQuery(Query query);
  List<DocumentSnapshot> onSnapshots(List<DocumentSnapshot> snapshosts);

  Map<String, dynamic> backup() {
    return {};
  }

  void restaure(Map<String, dynamic> state) {}
}

class StartAtStrategyFront extends _StartAtStrategy {
  Set<String> ids = Set();
  Query onQuery(Query query) {
    return query;
  }

  List<DocumentSnapshot> onSnapshots(List<DocumentSnapshot> snapshosts) {
    return snapshosts.where((test) {
      final fetched = this.ids.contains(test.documentID);
      ids.add(test.documentID);
      return !fetched;
    }).toList();
  }

  Map<String, dynamic> backup() {
    return {'ids': ids};
  }

  void restaure(Map<String, dynamic> state) {
    if (state != null) {
      this.ids = state['ids'] ?? ids;
    }
  }
}

class StartAtStrategyBack extends _StartAtStrategy {
  String _lastId;
  Map<String, dynamic> _lastData;
  final NFirebaseCursor cursor;
  StartAtStrategyBack(this.cursor);
  Query onQuery(Query query) {
    if (_lastData != null) {
      List<dynamic> values = [];
      this
          .cursor
          .orderFields()
          .forEach((field) => values.add({field: _lastData[field]}));
      //if (!isOrderedById) {
      //values.add({'id': null});
      //}
      query = query.startAt(values);
    }
    return query;
  }

  List<DocumentSnapshot> onSnapshots(List<DocumentSnapshot> snapshosts) {
    if (snapshosts.length > 0) {
      //copy data to avoid side effect
      this._lastId = snapshosts.last.documentID;
      this._lastData = Map.from(snapshosts.last.data);
    }
    return snapshosts;
  }

  Map<String, dynamic> backup() {
    return {'_lastId': _lastId, '_lastData': _lastData};
  }

  void restaure(Map<String, dynamic> state) {
    if (state != null) {
      this._lastId = state['_lastId'] ?? _lastId;
      this._lastData = state['_lastData'] ?? _lastData;
    }
  }
}

abstract class NFirebaseCursor<T> {
  bool _finished = false;
  bool _cancelled = false;
  int _totalFetched = 0;
  _StartAtStrategy _startAtStrategy;
  NFirebaseCursor(StartAtStrategy startAtStrategy) {
    switch (startAtStrategy) {
      case StartAtStrategy.Back:
        this._startAtStrategy = new StartAtStrategyBack(this);
        break;
      case StartAtStrategy.Front:
        this._startAtStrategy = new StartAtStrategyFront();
        break;
    }
  }
  //abstract part
  Query toQuery();
  List<String> orderFields();
  T transform(DocumentSnapshot snap, String id);
  bool filter(T t);
  int sort(T object1, T object2);
  int minNumberOfData();
  int limit();
  bool isFinished(int count);
  //

  Map<String, dynamic> backup() {
    return {
      '_finished': _finished,
      '_cancelled': _cancelled,
      '_totalFetched': _totalFetched,
      '_startAtStrategy': _startAtStrategy.backup()
    };
  }

  void restaure(Map<String, dynamic> state) {
    if (state != null) {
      this._finished = state['_finished'] ?? _finished;
      this._cancelled = state['_cancelled'] ?? _cancelled;
      this._totalFetched = state['_totalFetched'] ?? _totalFetched;
      this._startAtStrategy.restaure(state['_startAtStrategy']);
    }
  }

  //
  Future<List<T>> _fetchNext() async {
    Query query = this.toQuery();
    var limit = this.limit();
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }
    query = this._startAtStrategy.onQuery(query);
    //
    final QuerySnapshot snapshosts = await query.getDocuments();
    final List<DocumentSnapshot> documents =
        this._startAtStrategy.onSnapshots(snapshosts.documents);
    final List<T> entities =
        documents.map((doc) => this.transform(doc, doc.documentID)).toList();
    final List<T> filtered =
        entities.where((entity) => this.filter(entity)).toList();
    filtered.sort(this.sort);
    return filtered;
  }

  _shouldContinueFetch({List<T> current, int currentFetchCount}) {
    return currentFetchCount < this.minNumberOfData() &&
        !this.isFinished(_totalFetched) &&
        !_cancelled;
  }

  Future<List<T>> next() async {
    final List<T> all = [];
    List<T> res;
    while (_shouldContinueFetch(current: res, currentFetchCount: all.length)) {
      res = await this._fetchNext();
      all.addAll(res);
      this._totalFetched += res.length;
    }
    this._finished = true;
    return all;
  }

  _stream(Subject<List<T>> s) async {
    int count = 0;
    List<T> res;
    while (_shouldContinueFetch(current: res, currentFetchCount: count)) {
      res = await this._fetchNext();
      s.add(res);
      count += res.length;
      this._totalFetched += res.length;
    }
    this._finished = true;
    s.close();
  }

  Observable<List<T>> nextStream() {
    Subject<List<T>> subject = BehaviorSubject();
    this._stream(subject);
    return subject;
  }

  stop() {
    if (!this._finished) {
      this._cancelled = true;
    }
  }

  bool get finished => this.isFinished(this._totalFetched);
  bool get cancelled => _cancelled;
}
