import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import '../layout_listener.dart';
import 'controller.dart';

class LayoutListener extends SingleChildRenderObjectWidget {
  final IndexedListController controller;
  final int index;
  const LayoutListener(
      {@required this.index, @required this.controller, Key key, Widget child})
      : assert(index != null, "missing index"),
        assert(controller != null, "missing IndexedListController"),
        super(key: key, child: child);

  void updateRenderObject(BuildContext context,
      covariant RenderSizeChangedWithCallback renderObject) {
    super.updateRenderObject(context, renderObject);
    //dont try to get size => throw exception
    if (renderObject.oldSize != null) {
      controller?.setSize(index: index, currentSize: renderObject.oldSize);
    }
  }

  @override
  RenderSizeChangedWithCallback createRenderObject(BuildContext context) {
    return RenderSizeChangedWithCallback(
        index: index,
        onLayoutChangedCallback: (Size size, {Size oldSize}) {
          controller?.setSize(
              index: index, currentSize: size, previousSize: oldSize);
        });
  }
}
