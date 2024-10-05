import 'package:flutter/widgets.dart';
import '../store.dart';

class StoreProvider extends InheritedWidget {
  final Store _store;

  const StoreProvider({Key key, @required Store store, @required Widget child})
      : assert(store != null),
        assert(child != null),
        _store = store,
        super(key: key, child: child);

  static Store of(BuildContext context) {
    final StoreProvider provider =
        context.inheritFromWidgetOfExactType(StoreProvider);

    if (provider == null)
      throw "Could not found store in context. Have you defined root StoreProvider?";

    return provider._store;
  }

  static T getStore<T>(BuildContext context, Type type) {
    return StoreProvider.of(context).getStore(type);
  }

  static T getState<T>(BuildContext context, Type storeType, Type type) {
    return StoreProvider.of(context).getStore(storeType).getStateFor(type);
  }

  //static Type _typeOf<T>() => T;

  @override
  bool updateShouldNotify(StoreProvider old) => _store != old._store;
}
