import 'package:flutter/widgets.dart';

class IndexedListViewPadding extends InheritedWidget {
  final double padding;
  const IndexedListViewPadding(
      {Key key, @required this.padding, @required Widget child})
      : assert(padding != null),
        assert(child != null),
        super(key: key, child: child);

  static IndexedListViewPadding of(BuildContext context) {
    final IndexedListViewPadding provider =
        context.inheritFromWidgetOfExactType(IndexedListViewPadding);
    return provider;
  }

  //static Type _typeOf<T>() => T;

  @override
  bool updateShouldNotify(IndexedListViewPadding old) => padding != old.padding;
}
