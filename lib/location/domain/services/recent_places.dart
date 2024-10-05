import 'dart:async';
import 'dart:collection';
import 'package:localstorage/localstorage.dart';
import '../models.dart';

_uniquePlace(List<GeoPlace> places) {
  if (places != null) {
    //sort by insert
    Map<String, GeoPlace> keys = LinkedHashMap();
    for (GeoPlace place in places) {
      final key = "${place?.position?.latitude}-${place?.position?.longitude}";
      keys.putIfAbsent(key, () => place);
    }
    return keys.values.toList();
  }
  return places;
}

mixin RecentPlacesMixin {
  final LocalStorage storage = new LocalStorage('locations');
  Future<List<GeoPlace>> getRecentPlaces() async {
    await storage.ready;
    final recent = storage.getItem('recents');
    List<Map<String, dynamic>> json = recent?.cast<Map<String, dynamic>>();
    if (json == null) {
      return [];
    } else {
      return _uniquePlace(json.map((f) => GeoPlace.fromJson(f)).toList());
    }
  }

  Future<bool> setRecentPlaces(List<GeoPlace> places) async {
    final json = _uniquePlace(places).map((f) => f.toJson()).toList();
    await storage.ready;
    storage.setItem("recents", json);
    return true;
  }

  Future<GeoPlace> addToRecentPlace(GeoPlace place) async {
    final places = await this.getRecentPlaces();
    places.add(place);
    await this.setRecentPlaces(places);
    return place;
  }

  Future<void> removeRecentPlaces() async {
    await storage.ready;
    storage.deleteItem("recents");
  }
}
