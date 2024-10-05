import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

typedef void OnLayoutChangedCallback(Size size, {Size oldSize});

class LayoutListenerGeneric extends SingleChildRenderObjectWidget {
  final OnLayoutChangedCallback sizeChanged;
  final int index;
  const LayoutListenerGeneric(
      {@required this.index, @required this.sizeChanged, Key key, Widget child})
      : assert(index != null, "missing index"),
        assert(sizeChanged != null, "missing sizeChanged callback"),
        super(key: key, child: child);

  void updateRenderObject(BuildContext context,
      covariant RenderSizeChangedWithCallback renderObject) {
    super.updateRenderObject(context, renderObject);
    //dont try to get size => throw exception
    if (renderObject._oldSize != null) {
      sizeChanged(renderObject._oldSize);
    }
  }

  @override
  RenderSizeChangedWithCallback createRenderObject(BuildContext context) {
    return RenderSizeChangedWithCallback(
        index: index,
        onLayoutChangedCallback: (Size size, {Size oldSize}) {
          sizeChanged(size, oldSize: oldSize);
        });
  }
}

class RenderSizeChangedWithCallback extends RenderProxyBox {
  Size _oldSize;
  final int index;
  final OnLayoutChangedCallback onLayoutChangedCallback;
  RenderSizeChangedWithCallback(
      {RenderBox child, @required this.onLayoutChangedCallback, this.index})
      : assert(onLayoutChangedCallback != null),
        super(child);
  Size get oldSize => _oldSize;
  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) onLayoutChangedCallback(size, oldSize: _oldSize);
    _oldSize = size;
  }
}
