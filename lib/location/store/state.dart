import '../domain/domain.dart';

class LocationState {
  GeoAddressResult current;
  List<GeoPlace> searchResults = [];
  String textSearch;
  bool searching = false;
  bool emptyResult = false;
  bool isGeolocalizing = false;
  int nbGeolocalisation = 0;
  //
  DateTime recentsFetchedOn;
  List<GeoPlace> recents = [];
  //
  LocationState copy() {
    var copy = LocationState();
    copy
      ..current = this.current
      ..searchResults = this.searchResults
      ..textSearch = this.textSearch
      ..searching = this.searching
      ..emptyResult = this.emptyResult
      ..recentsFetchedOn = this.recentsFetchedOn
      ..recents = this.recents
      ..nbGeolocalisation = this.nbGeolocalisation;
    return copy;
  }

  get hasCurrent => this.current != null;
  get hasFetchRecentPlaces => this.recentsFetchedOn != null;
}
