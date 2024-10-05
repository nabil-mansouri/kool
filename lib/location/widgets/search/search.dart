import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/multiflow/multiflow.dart';
import 'view_model.dart';
import 'search_input.dart';
import '../commons/commons.dart';
import '../../domain/domain.dart';
import '../../store/store.dart';
export 'search_input.dart';

typedef OnCloseLocationSearch = void Function();

class LocationSearchWidget extends StatelessWidget {
  final SearchViewModel model;
  final OnSelectLocationSearch onSelect;
  final OnCloseLocationSearch onClose;
  LocationSearchWidget(this.model, {this.onClose, this.onSelect});
  _select(BuildContext context, GeoPlace place) {
    if (this.onSelect != null) {
      this.onSelect(place);
    }
  }

  _buildRecent(BuildContext context) {
    List<Widget> children = [];
    int index = 0;
    children.add(ListTile(
        title: Text(
      "Adresses récentes",
      style: TextStyle(color: Colors.black54, fontSize: 14),
    )));
    model.recents.forEach((place) {
      if (index > 0) {
        children.add(Divider());
      }
      children.add(GeoPlaceRow(
          place: place,
          isSelected: false, //dont display selection
          onSelect: (place) => _select(context, place)));
      index++;
    });
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 12),
        child: Column(children: children));
  }

  _buildResult(BuildContext context) {
    List<Widget> children = [];
    int index = 0;
    model.searchResults.forEach((place) {
      if (index > 0) {
        children.add(Divider());
      }
      children.add(GeoPlaceRow(
          place: place,
          isSelected: false,
          onSelect: (place) => _select(context, place)));
      index++;
    });
    return Container(color: Colors.white, child: Column(children: children));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(LocationSearchInput(
      hint: "Rechercher une adresse",
      controller: model.searchText,
      onCancel: () {
        if (this.onClose != null) this.onClose();
      },
    ));
    // === Display searching
    if (model.searching) {
      children.add(CircularProgressIndicator());
    }
    // === Display recent address or search result
    if (model.hasResult) {
      children.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: _buildResult(context)));
    } else {
      if (model.emptyResult && model.hasTextSearch) {
        children.add(Padding(
            padding: EdgeInsets.only(top: 16),
            child: Container(
              child: Text(
                "Aucun résultat: " + model.searchText.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )));
      } else {
        // === Display current position
        children.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CurrentGeoPlaceRow(
                  askPerms: () => model.askPerm(context),
                  current: model.current,
                  isSelected: false,
                  needPerms: model.needPermsOrDenied,
                  onSelect: (c) => _select(context, c),
                ))));
        // === Display recents
        if (model.hasRecent) {
          children.add(_buildRecent(context));
        }
      }
    }
    //
    return ListView(shrinkWrap: true, children: children);
  }
}

class LocationSearchContainer extends StatelessWidget {
  final OnCloseLocationSearch onClose;
  final OnSelectLocationSearch onSelect;
  LocationSearchContainer({this.onClose, this.onSelect});
  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<SearchViewModel>.fromFactory(
        modelFactory: () {
      final model = SearchViewModel();
      model.getCurrentPositionIfNotAlready(context);
      return model;
    }, builder: (context, model) {
      return LocationSearchWidget(
        model,
        onClose: onClose,
        onSelect: onSelect,
      );
    });
  }
}

showModalSearchContainer(BuildContext context,
    {bool fullScreen = true,
    bool closeOnSelect = false,
    OnSelectLocationSearch onSelect,
    GeoPlace selectedPlace}) {
  return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: LocationRoutes.LOCATION_SEARCH),
      builder: (context) => Scaffold(
          backgroundColor: Colors.grey.shade300,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: LocationSearchContainer(
                onSelect: (place) async {
                  if (onSelect != null) onSelect(place);
                  if (closeOnSelect) {
                    Navigator.pop(context);
                  }
                },
                onClose: () {
                  Navigator.pop(context);
                },
              ))),
      fullscreenDialog: fullScreen));
}
