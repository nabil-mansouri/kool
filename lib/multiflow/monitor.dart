import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'store.dart';
import 'actions.dart';
import 'workflow/workflow.dart';
import 'navigation/navigation.dart';

enum MonitorEventKind {
  BeforeReduce,
  AfterReduce,
  OnWorkflowAction,
  OnAddWorkflowChild,
  OnRemoveWorkflowChild,
  OnRegisterEffect
}

class MonitorEvent<STATE> {
  final Action action;
  final STATE state;
  final STATE previousState;
  final Workflow workflow;
  final MonitorEventKind kind;
  final Effect effect;
  MonitorEvent(
      {this.action,
      this.state,
      this.previousState,
      this.kind,
      this.workflow,
      this.effect});
}

class StoreMonitor<STATE> implements StoreAware<STATE>, WorkflowAware<STATE> {
  final Subject<MonitorEvent<STATE>> _stream = PublishSubject();
  Observable<MonitorEvent<STATE>> get stream => _stream;
  bool log = false;

  bool _accept(MonitorEvent<STATE> test,
      {MonitorEventKind kind,
      Action action,
      String route,
      Type onWorkflowType}) {
    var accept = true;
    if (kind != null) {
      accept = accept && kind == test.kind;
    }
    if (action != null) {
      accept = accept && test.action != null && action.key == test.action.key;
    }
    if (route != null && test?.action != null && test?.action is RouteAction) {
      accept = accept && route == (test.action as RouteAction).current;
    }
    if (onWorkflowType != null) {
      accept =
          test.workflow != null && onWorkflowType == test.workflow.runtimeType;
    }
    return accept;
  }

  Future<MonitorEvent<STATE>> waitForFirst(
      {MonitorEventKind kind,
      bool distinct = false,
      Action action,
      String route,
      Type onWorkflowType}) {
    var stream = this.stream;
    if (distinct) {
      stream = stream.distinct();
    }
    stream = stream.where((test) => this._accept(test,
        kind: kind,
        action: action,
        route: route,
        onWorkflowType: onWorkflowType));
    stream = _log("[WaitForFirst][Then]", stream);
    return stream.first;
  }

  Future<MonitorEvent<STATE>> waitForLast(
      {MonitorEventKind kind,
      bool distinct = false,
      Action action,
      String route,
      Type onWorkflowType}) {
    var stream = this.stream;
    if (distinct) {
      stream = stream.distinct();
    }
    return stream
        .where((test) => this._accept(test,
            kind: kind,
            action: action,
            route: route,
            onWorkflowType: onWorkflowType))
        .last;
  }

  Observable<MonitorEvent<STATE>> _log(
      String prefix, Observable<MonitorEvent<STATE>> source) {
    if (!this.log) {
      return source;
    }
    return source.map((convert) {
      print("$prefix  ${convert.kind} ${convert.action?.key}");
      return convert;
    });
  }

  Future<MonitorEvent<STATE>> waitForEventAfter(Future future,
      {MonitorEventKind kind,
      bool distinct = true,
      Action action,
      String route,
      Type onWorkflowType}) {
    var stream = this.stream;
    stream = _log("[WaitForEvent][Before]", stream);
    if (distinct) {
      stream = stream.distinct();
    }
    stream = stream.skipUntil(Observable.fromFuture(future));
    stream = _log("[WaitForEvent][AfterSkipUntil]", stream);
    stream = stream.skip(1);
    stream = _log("[WaitForEvent][AfterSkip1]", stream);
    return stream
        .where((test) => this._accept(test,
            action: action,
            kind: kind,
            route: route,
            onWorkflowType: onWorkflowType))
        .first;
  }

  void beforeReduce(
      Action<Object> action, STATE previousState, STATE currentState) {
    this._stream.add(MonitorEvent(
        action: action,
        state: currentState,
        previousState: previousState,
        kind: MonitorEventKind.BeforeReduce));
  }

  void afterReduce(
      Action<Object> action, STATE previousState, STATE currentState) {
    this._stream.add(MonitorEvent(
        action: action,
        state: currentState,
        previousState: previousState,
        kind: MonitorEventKind.AfterReduce));
  }

  void onAction(Workflow workflow, Action action, STATE state) {
    this._stream.add(MonitorEvent(
        action: action,
        state: state,
        workflow: workflow,
        kind: MonitorEventKind.OnWorkflowAction));
  }

  void onAddWorkflowChild(Workflow workflow) {
    workflow.addListener(this);
    this._stream.add(MonitorEvent(
        workflow: workflow, kind: MonitorEventKind.OnAddWorkflowChild));
  }

  void onRemoveWorkflowChild(Workflow workflow) {
    this._stream.add(MonitorEvent(
        workflow: workflow, kind: MonitorEventKind.OnRemoveWorkflowChild));
    workflow.removeListener(this);
  }

  void onRegisterEffect(Workflow workflow, Effect e) {
    this._stream.add(MonitorEvent(
        workflow: workflow,
        effect: e,
        kind: MonitorEventKind.OnRegisterEffect));
  }
}
