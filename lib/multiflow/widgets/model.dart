import 'package:scoped_model/scoped_model.dart';
import 'package:optional/optional.dart';
import 'package:flutter/widgets.dart';
import '../store.dart';
import '../actions.dart';
import 'provider.dart';

typedef ConnectedScopeBuilder<MODEL extends AbstractModel> = Widget Function(
    BuildContext context, MODEL model);

typedef OnStoreModelChanged<MODEL extends AbstractModel> = Function(
    BuildContext context, MODEL model);

typedef ModelFactory<MODEL extends AbstractModel> = MODEL Function();

enum DisposeModel { DisposeNewModel, DisposeOldModel }

class ModelValue<T> {
  T localValue;
  T stateValue;
  T get localElseState => localValue ?? stateValue;
  T get stateElseLocal => stateValue ?? localValue;
  bool get hasLocal => localValue != null;
  bool get hasState => stateValue != null;
  bool get hasAny => hasLocal || hasState;
  bool get allEmpty => !hasAny;
  cleanLocal() => localValue = null;
  cleanState() => stateValue = null;
}

typedef ModelObjectGetter<T, VAL> = VAL Function(T object);

class ModelObject<T> {
  T localObject;
  T stateObject;
  bool get hasLocal => localObject != null;
  bool get hasState => stateObject != null;
  VAL getLocalElseState<VAL>(ModelObjectGetter<T, VAL> getter) {
    if (hasLocal) {
      final res = getter(localObject);
      if (res != null) {
        return res;
      }
    }
    if (hasState) {
      final res = getter(stateObject);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  VAL getStateElseLocal<VAL>(ModelObjectGetter<T, VAL> getter) {
    if (hasState) {
      final res = getter(stateObject);
      if (res != null) {
        return res;
      }
    }
    if (hasLocal) {
      final res = getter(localObject);
      if (res != null) {
        return res;
      }
    }
    return null;
  }
}

abstract class AbstractModel<STATE> extends Model {
  bool refresh(STATE state);
  Type stateType() => STATE;
  Optional<BuildContext> lastContext;
  @mustCallSuper
  void onBuild(BuildContext context) {
    lastContext = Optional.of(context);
  }

  @mustCallSuper
  void onInitState(Store store) {
    STATE state = store.getStateFor(stateType());
    this.refresh(state);
  }

  @mustCallSuper
  DisposeModel onWidgetChanged(covariant AbstractModel<STATE> newModel) {
    lastContext = Optional.empty(); //if widget changes => context changes
    // by default new model is only use to update the old one
    return DisposeModel.DisposeNewModel;
  }

  @mustCallSuper
  void onStoreChanged(Store store) {
    STATE state = store.getStateFor(stateType());
    this.refresh(state);
  }

  @mustCallSuper
  void onAction(Action action) {}

  @mustCallSuper
  void onStateChanged(Store store, Action action) {
    STATE state = store.getStateFor(stateType());
    this.onAction(action);
    var changed = this.refresh(state);
    if (changed) {
      notifyListeners();
    }
  }

  T getStore<T extends Store>(BuildContext context, Type type) {
    return StoreProvider.getStore(context, type);
  }

  static T storeOf<T extends Store>(BuildContext context, Type type) {
    return StoreProvider.getStore(context, type);
  }

  @mustCallSuper
  void onDispose() {
    lastContext = Optional.empty();
  }
}

class ConnectedScopedModelBuilder<MODEL extends AbstractModel>
    extends StatelessWidget {
  final bool keepAlive;
  final OnStoreModelChanged<MODEL> onStoreChanged;
  final ConnectedScopeBuilder<MODEL> builder;
  final ModelFactory<MODEL> modelFactory;
  ConnectedScopedModelBuilder._internal(
      {@required this.builder,
      @required this.modelFactory,
      this.keepAlive = false,
      this.onStoreChanged});

  factory ConnectedScopedModelBuilder.fromModel(
      {@required ConnectedScopeBuilder<MODEL> builder,
      @required MODEL model,
      bool keepAlive,
      OnStoreModelChanged<MODEL> onStoreChanged}) {
    return ConnectedScopedModelBuilder._internal(
        builder: builder,
        modelFactory: () => model,
        keepAlive: keepAlive,
        onStoreChanged: onStoreChanged);
  }

  factory ConnectedScopedModelBuilder.fromFactory(
      {@required ConnectedScopeBuilder<MODEL> builder,
      @required ModelFactory<MODEL> modelFactory,
      bool keepAlive,
      OnStoreModelChanged<MODEL> onStoreChanged}) {
    return ConnectedScopedModelBuilder._internal(
        builder: builder,
        modelFactory: modelFactory,
        keepAlive: keepAlive,
        onStoreChanged: onStoreChanged);
  }
  Widget build(BuildContext context) {
    var store = StoreProvider.of(context);
    return _StoreModelWidget<MODEL>(
        store: store,
        keepAlive: keepAlive,
        builder: builder,
        model: this.modelFactory(),
        onStoreChanged: this.onStoreChanged);
  }
}

class _StoreModelWidget<MODEL extends AbstractModel> extends StatefulWidget {
  final bool keepAlive;
  final Store<Object> store;
  //use model instead of factory=>if model changes => widget changes
  final MODEL model;
  final ConnectedScopeBuilder<MODEL> builder;
  final OnStoreModelChanged<MODEL> onStoreChanged;
  _StoreModelWidget(
      {Key key,
      @required this.store,
      @required this.model,
      @required this.builder,
      this.keepAlive = false,
      this.onStoreChanged})
      : assert(model != null, "ScopeModel should have a model as parameter"),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StoreModelState<MODEL>(model);
  }
}

class _StoreModelState<MODEL extends AbstractModel>
    extends State<_StoreModelWidget<MODEL>> with StoreAware {
  MODEL model;
  _StoreModelState(this.model);
  Store<Object> get widgetStore => this.widget.store;

  beforeReduce(Action<Object> action, previousState, currentState) {}
  afterReduce(Action<Object> action, previousState, currentState) {
    if (this.mounted) {
      this.model.onStateChanged(this.widgetStore, action);
    }
    if (this.widget.onStoreChanged != null) {
      this.widget.onStoreChanged(context, this.model);
    }
  }

  @override
  void initState() {
    this.widgetStore.addListener(this);
    this.model.onInitState(this.widgetStore);
    super.initState();
  }

  @override
  void dispose() {
    this.widgetStore.removeListener(this);
    this.model.onDispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_StoreModelWidget oldWidget) {
    if (this.widget != oldWidget) {
      //If store has changed => listen to new store
      if (oldWidget.store != this.widgetStore) {
        oldWidget.store.removeListener(this);
        this.widgetStore.addListener(this);
        this.model.onStoreChanged(this.widgetStore);
      }
      // if model has changed
      final newModel = this.widget.model;
      if (this.model != newModel) {
        final result = this.model.onWidgetChanged(newModel);
        // update old model (maybe initial param has changed) then dispose the new one
        if (result == DisposeModel.DisposeNewModel) {
          newModel.onDispose();
        }
        //use the new model instead the old one => dispose the old and init the new
        else if (result == DisposeModel.DisposeOldModel) {
          this.model.onDispose();
          this.model = newModel;
          this.model.onInitState(this.widgetStore);
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    this.model.onBuild(context);
    final child = ScopedModel<MODEL>(
        model: this.model,
        child: ScopedModelDescendant<MODEL>(builder: (context, widget, model) {
          return this.widget.builder(context, model);
        }));
    if (widget.keepAlive == true) {
      return KeepAlive(keepAlive: widget.keepAlive, child: child);
    } else {
      return child;
    }
  }
}
