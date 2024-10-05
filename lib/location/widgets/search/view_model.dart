import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../store/store.dart';
import '../commons/commons.dart';

class SearchViewModel extends AbstractFormModel<LocationState>
    with SelectPlaceViewModelMixin {
  bool searching = false;
  bool emptyResult = false;
  List<GeoPlace> searchResults = [];
  FormFieldController<LocationState> searchText;
  //
  SearchViewModel() {
    searchText = createFormFieldController(
        debounceChangesInMs: 200,
        getter: (state) => (state as LocationState)?.textSearch,
        onChange: (text) => search(text));
  }

  get hasResult => this.searchResults.length > 0;
  get hasTextSearch => this.searchText.hasValue;

  bool refresh(LocationState state) {
    bool changed = false;
    if (state.searching != this.searching) {
      this.searching = state.searching;
      changed = true;
    }
    if (state.searchResults != this.searchResults) {
      this.searchResults = state.searchResults;
      changed = true;
    }
    if (state.emptyResult != this.emptyResult) {
      this.emptyResult = state.emptyResult;
      changed = true;
    }
    if (refreshSelectMixin(state)) {
      changed = true;
    }
    return changed;
  }

  LocationStore getLocationStore(BuildContext context) {
    return getStore<LocationStore>(context, LocationStore);
  }

  getCurrentPositionIfNotAlready(BuildContext context) {
    getLocationStore(context).getCurrentPositionIfNotAlready(
        askPermIfNeeded: true, lastKnownIfneeded: true);
  }

  search(String text) {
    final _lastContext = lastContext.orElseGet(() => null);
    if (_lastContext != null) {
      getLocationStore(_lastContext).searchPlace(text, keepOnlyAddress: true);
      notifyListeners();
    }
  }
}
