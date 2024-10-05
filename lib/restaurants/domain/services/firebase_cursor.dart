import 'package:food/commons/firebase_cursor.dart';
import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:meta/meta.dart';
import 'contract.dart';
import '../models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_daos.dart';

class RestaurantListCursorImpl extends NFirebaseCursor<RestaurantModel>
    with RestaurantListCursor {
  final RestaurantQuery query;
  final RestaurantFirebaseDao restoDao;
  final bool backendFilter = false;
  final double maxRadius;
  final double addRadius;
  int _minNumberOfData;
  double currentRadius = 0;
  RestaurantListCursorImpl(this.query, this.restoDao,
      {@required int minNumberOfData,
      @required this.maxRadius,
      @required this.addRadius})
      : super(StartAtStrategy.Front) {
    this._minNumberOfData = minNumberOfData;
  }

  Map<String, dynamic> backup() {
    var backup = super.backup();
    backup.addAll({
      '_minNumberOfData': _minNumberOfData,
      'currentRadius': currentRadius,
    });
    return backup;
  }

  RestaurantListCursor restaure(Map<String, dynamic> state) {
    super.restaure(state);
    if (state != null) {
      this._minNumberOfData = state['_minNumberOfData'] ?? _minNumberOfData;
      this.currentRadius = state['currentRadius'] ?? currentRadius;
    }
    return this;
  }

  int limit() {
    return this.query.limit;
  }

  int minNumberOfData() {
    return this._minNumberOfData;
  }

  bool isFinished(int totalFetched) {
    var limit = this.query.limit ?? 500;
    return this.currentRadius > this.maxRadius || totalFetched > limit;
  }

  bool get hasNext => currentRadius < maxRadius;

  List<String> orderFields() {
    List<String> fields = [];
    fields.add("position");
    return fields;
  }

  int sort(RestaurantModel resto1, RestaurantModel resto2) {
    switch (query.order) {
      case RestaurantOrderQuery.Delay:
        return resto1.delayMean.compareTo(resto2.delayMean); //shorter first
      case RestaurantOrderQuery.Popularity:
        return resto1.popularity.compareTo(resto2.popularity) *
            -1; //bigger first
      case RestaurantOrderQuery.Price:
        return resto1.priceMean.compareTo(resto2.priceMean); //shortter first
      case RestaurantOrderQuery.Notes:
        return resto1.rating.compareTo(resto2.rating) * -1; //descending
      case RestaurantOrderQuery.Position:
        return resto1.distance.compareTo(resto2.distance); //shorter first
    }
    return 1;
  }

  Query toQuery() {
    Query fQuery = this.restoDao.ref;
    this.currentRadius += this.addRadius;
    if (query.location != null) {
      final center =
          GeoPoint(query.location.latitude, query.location.longitude);
      final GeoBoundingBox box =
          boundingBoxCoordinates(Area(center, this.currentRadius));
      final lesserGeopoint =
          GeoPoint(box.swCorner.latitude, box.swCorner.longitude);
      var greaterGeopoint =
          GeoPoint(box.neCorner.latitude, box.neCorner.longitude);
      fQuery = fQuery
          .where('position', isGreaterThanOrEqualTo: lesserGeopoint)
          .where('position', isLessThanOrEqualTo: greaterGeopoint);
    }
    if (this.backendFilter) {
      fQuery = this.restoDao.toQuery(fQuery, this.query);
    }
    //must sort by position when inequality
    fQuery = fQuery.orderBy('position', descending: false);
    return fQuery;
  }

  bool filter(RestaurantModel model) {
    if (this.backendFilter) {
      return true;
    }
    if (query.acceptTicket != null &&
        query.acceptTicket &&
        !model.acceptTicket) {
      return false;
    }
    if (query.importantTag != null &&
        !model.tags.contains(query.importantTag)) {
      return false;
    }
    if (query.tag != null && !model.tags.contains(query.tag)) {
      return false;
    }
    if (query.nameSearch != null &&
        !model.nameSearch.startsWith(query.nameSearch)) {
      return false;
    }
    return true;
  }

  RestaurantModel transform(snap, String id) {
    return this.restoDao.fromFirebase(snap.data, id: id, query: this.query);
  }
}
