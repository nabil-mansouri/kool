import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../store/store.dart';

mixin SelectPlaceViewModelMixin {
  GeoPlace current;
  GeoStatus status;
  bool needPerm = false;
  bool isGeolocalizing = false;
  List<GeoPlace> recents = [];
  //
  LocationStore getLocationStore(BuildContext context);
  //
  get hasCurrent => this.current != null;
  get hasRecent => this.recents.length > 0;
  get denied => this.status == GeoStatus.denied;
  get needPermsOrDenied => this.needPerm || this.denied;

  askPerm(BuildContext context) {
    getLocationStore(context)
        .getCurrentPosition(lastKnownIfneeded: false, askPermIfNeeded: true);
  }

  bool refreshSelectMixin(LocationState state) {
    bool changed = false;
    if (state.current?.place != this.current) {
      this.current = state.current?.place;
      changed = true;
    }
    if (state.isGeolocalizing != this.isGeolocalizing) {
      this.isGeolocalizing = state.isGeolocalizing;
      changed = true;
    }
    if (state.current?.needPerms != this.needPerm) {
      //avoid null
      this.needPerm = state.current?.needPerms == true;
      changed = true;
    }
    if (state.current?.status != this.status) {
      //avoid null
      this.status = state.current?.status;
      changed = true;
    }
    if (state.recents != this.recents) {
      this.recents = state.recents;
      changed = true;
    }
    return changed;
  }
}
