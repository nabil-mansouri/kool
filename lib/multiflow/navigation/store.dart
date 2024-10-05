import '../store.dart';
import './actions.dart';

class NavigationState {
  String currentRoute;
  List<String> history = [];
  copy() {
    var copy = NavigationState();
    copy
      ..currentRoute = this.currentRoute
      ..history = this.history;
    return copy;
  }
}

class NavigationStore extends Store<NavigationState> {
  NavigationStore() : super(NavigationState()) {
    this.addReducerForAction<Routes>(NavigationActions.doChanged,
        Reducer((action, state) {
      RouteAction routeAction = action;
      NavigationChange change = routeAction
          .getArgOfType(NavigationChange, null)
          .orElseThrow(() => "Could not found NavigationCHange type");
      state = state.copy();
      state.history = List<String>.from(state.history);
      if (change == NavigationChange.Push) {
        state.history.add(action.payload.current);
        state.currentRoute = state.history.last;
        print("[Navigation] navigating PUSH to: ${action.payload.current}");
      } else {
        //remove
        var index = state.history.lastIndexOf(action.payload.previous);
        if (state.history.length - 1 == index)
          state.history.removeLast();
        else
          print(
              "Previous route ${action.payload.previous} is not the last in history: ${state.history}");
        //add
        //state.history.add(action.payload.previous);
        state.currentRoute = state.history.last;
        print("[Navigation] navigating POP from: ${action.payload.previous}");
      }
      return state;
    }));
  }
}
