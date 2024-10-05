import 'package:flutter/widgets.dart';
import '../store.dart';
import '../actions.dart';
import 'provider.dart';

typedef WidgetBuilderFromStore<STATE> = Widget Function(
    BuildContext context, Store<STATE> store, Action action);

typedef OnStoreChanged<STATE> = void Function(
    BuildContext context, Store<STATE> store, Action action);

typedef bool StateWasUpdated(Store store);

class StoreListenerWidget extends StatelessWidget {
  final WidgetBuilderFromStore builder;
  final StateWasUpdated shouldUpdate;
  final OnStoreChanged onStoreChanged;
  StoreListenerWidget(
      {Key key,
      @required this.builder,
      this.shouldUpdate,
      this.onStoreChanged});
  build(context) {
    var store = StoreProvider.of(context);
    return _StoreListenerWidget(
      store: store,
      builder: this.builder,
      onStoreChanged: this.onStoreChanged,
    );
  }
}

class _StoreListenerWidget extends StatefulWidget {
  final WidgetBuilderFromStore builder;
  final Store<Object> store;
  final StateWasUpdated shouldUpdate;
  final OnStoreChanged onStoreChanged;
  _StoreListenerWidget(
      {Key key,
      @required this.store,
      @required this.builder,
      this.onStoreChanged,
      this.shouldUpdate})
      : assert(builder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StoreListenerState();
  }
}

class _StoreListenerState extends State<_StoreListenerWidget> with StoreAware {
  Action _lastAction;

  Store<Object> get widgetStore => this.widget.store;

  beforeReduce(Action<Object> action, previousState, currentState) {}
  afterReduce(Action<Object> action, previousState, currentState) {
    if (this.mounted) {
      if (this.widget.shouldUpdate != null) {
        if (!this.widget.shouldUpdate(this.widgetStore)) {
          return;
        }
      }
      if (this.widget.onStoreChanged != null) {
        this.widget.onStoreChanged(context, this.widgetStore, action);
      }
      setState(() {
        this._lastAction = action;
      });
    }
  }

  @override
  void initState() {
    this.widgetStore.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    this.widgetStore.removeListener(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(_StoreListenerWidget oldWidget) {
    if (this.widgetStore != oldWidget.store) {
      oldWidget.store.removeListener(this);
      this.widgetStore.addListener(this);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(context, this.widgetStore, this._lastAction);
  }
}
