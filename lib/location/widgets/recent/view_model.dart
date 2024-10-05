import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/material.dart';
import '../../store/store.dart';
import '../commons/commons.dart';
import '../../domain/domain.dart';
import 'dart:math';

class RecentViewModel extends AbstractModel<LocationState>
    with SelectPlaceViewModelMixin {
  int limitRecent;
  GeoPlace selected;
  List<GeoPlace> exclude;
  RecentViewModel({this.exclude, this.selected, this.limitRecent = 20})
      : super();
  onWidgetChanged(RecentViewModel newModel) {
    this.exclude = newModel.exclude;
    this.selected = newModel.selected;
    this.limitRecent = newModel.limitRecent;
    notifyListeners();
    return super.onWidgetChanged(newModel);
  }

  LocationStore getLocationStore(BuildContext context) {
    return getStore<LocationStore>(context, LocationStore);
  }

  bool get hasSelected => selected != null;
  bool isCurrentSelected() {
    return current?.isEquals(selected) == true;
  }

  bool isSelected(GeoPlace place) {
    return place?.isEquals(selected) == true;
  }

  List<GeoPlace> get recentWithoutExcludes {
    final res = this.recents.where((test) {
      if (exclude != null) {
        for (GeoPlace p in exclude) {
          if (p.isEquals(test)) {
            return false;
          }
        }
      }
      if (current != null && current.isEquals(test)) {
        return false;
      }
      return true;
    }).toList();
    return res.sublist(0, min(this.limitRecent, res.length));
  }

  @override
  bool refresh(LocationState state) {
    return refreshSelectMixin(state);
  }
}
