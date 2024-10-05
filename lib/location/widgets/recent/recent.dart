import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'view_model.dart';
import '../commons/commons.dart';
import '../../domain/domain.dart';

class LocationRecentWidget extends StatelessWidget {
  final RecentViewModel model;
  final OnSelectLocationSearch onSelect;
  LocationRecentWidget(this.model, {this.onSelect});
  _select(BuildContext context, GeoPlace place) {
    if (this.onSelect != null) {
      this.onSelect(place);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final recent = model.recentWithoutExcludes;
    final isRecentSelected =
        recent.where((test) => model.isSelected(test)).length > 0;
    if (model.hasSelected && !isRecentSelected && !model.isCurrentSelected()) {
      children.add(GeoPlaceRow(
          place: model.selected,
          isSelected: true,
          onSelect: (place) => _select(context, place)));
      children.add(Divider());
    }
    // === Display current position
    children.add(CurrentGeoPlaceRow(
      askPerms: () => model.askPerm(context),
      current: model.current,
      isSelected: model.isCurrentSelected(),
      needPerms: model.needPermsOrDenied,
      onSelect: (c) => _select(context, c),
    ));
    if (recent.length > 0) {
      children.add(Divider());
      recent.forEach((place) {
        children.add(GeoPlaceRow(
            place: place,
            isSelected: model.isSelected(place),
            onSelect: (place) => _select(context, place)));
      });
    }
    //
    return Container(
        padding: recent.length == 0 ? EdgeInsets.only(bottom: 12) : null,
        color: Colors.white,
        child: Column(children: children));
  }
}

class LocationRecentContainer extends StatelessWidget {
  final int limitRecent;
  final GeoPlace selectedPlace;
  final List<GeoPlace> exclude;
  final OnSelectLocationSearch onSelect;
  LocationRecentContainer(
      {this.exclude, this.onSelect, this.selectedPlace, this.limitRecent});
  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<RecentViewModel>.fromModel(
        model: RecentViewModel(
            exclude: exclude,
            selected: selectedPlace,
            limitRecent: limitRecent),
        builder: (context, model) {
          return LocationRecentWidget(model, onSelect: onSelect);
        });
  }
}
