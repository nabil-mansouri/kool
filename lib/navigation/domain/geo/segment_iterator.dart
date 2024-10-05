import 'package:meta/meta.dart';
import 'geometry.dart';

class VectorIndexed {
  final Vector vector;
  final int index;
  VectorIndexed(this.vector, this.index);
}

abstract class SegmentIterator {
  void reset();
  void prepareNext(VectorTime movement, int currentIndex);
  VectorIndexed next();
  bool get hasNext;
}

class SegmentIteratorNeighboursUnidirectionnal implements SegmentIterator {
  final int increment;
  final PolyLine line;
  //cache
  int _currentIndex = 0;
  SegmentIteratorNeighboursUnidirectionnal(
      {@required this.line, @required this.increment}) {
    reset();
  }
  void prepareNext(VectorTime movement, int currentIndex) {
    _currentIndex = currentIndex;
  }

  void reset() {}

  bool get hasNext {
    return 0 <= _currentIndex && _currentIndex < line.countVectors;
  }

  VectorIndexed next() {
    final index = _currentIndex;
    final nextValue = line.vectors[index];
    _currentIndex += increment;
    return VectorIndexed(nextValue, index);
  }

  String toString() {
    return "[SegmentIteratorNeighboursUnidirectionnal,currentIndex=$_currentIndex,totalIndex=${line.countVectors},increment=$increment,hasNext=$hasNext]";
  }
}

class SegmentIteratorNeighboursLimitDistance implements SegmentIterator {
  final SegmentIterator child;
  final double defaultMaxDistanceMeters;
  final bool adaptative;
  final int adaptativeRatio;
  final int nbOfDistanceSkipped;
  //
  int _nbCheck = 0;
  double _totalDistance;
  double _lastDistance;
  VectorTime _lastMovement;
  SegmentIteratorNeighboursLimitDistance(
      {@required this.child,
      @required this.defaultMaxDistanceMeters,
      //skip the first segment distance => we could be at the end of the previous segment
      this.nbOfDistanceSkipped = 1,
      this.adaptative = false,
      this.adaptativeRatio = 10}) {
    reset();
  }

  String toString() {
    return "[SegmentIteratorNeighboursLimitDistance,maxDistanceInMeter=$maxDistanceInMeter,totalDistance=$_totalDistance,lastDistance=$_lastDistance,lastMovement=${_lastMovement?.distanceInMeter},hasNext=$hasNext,\n\tchild=${child.toString()}]";
  }

  void reset() {
    child.reset();
  }

  void prepareNext(VectorTime movement, int currentIndex) {
    _nbCheck = 0;
    _totalDistance = 0;
    _lastMovement = movement;
    if (adaptative) {
      _lastDistance = movement.distanceInMeter * adaptativeRatio;
      if (_lastDistance == 0) _lastDistance = defaultMaxDistanceMeters;
    }
    child.prepareNext(movement, currentIndex);
  }

  double get maxDistanceInMeter {
    return adaptative ? _lastDistance : defaultMaxDistanceMeters;
  }

  bool get hasNext {
    return child.hasNext && _totalDistance < maxDistanceInMeter;
  }

  VectorIndexed next() {
    final nextValue = child.next();
    if (_nbCheck >= nbOfDistanceSkipped) {
      _totalDistance += nextValue.vector.distanceInMeter;
    }
    _nbCheck++;
    return nextValue;
  }
}

class SegmentIteratorNeighboursBidirectionnal implements SegmentIterator {
  final SegmentIterator forward;
  final SegmentIterator backward;
  final bool forwardFirst;
  final int forwardWeight;
  final int backwardWeight;
  //
  SegmentIterator _current;
  int _counter;
  SegmentIteratorNeighboursBidirectionnal(
      {@required this.forward,
      @required this.backward,
      this.forwardFirst = true,
      this.forwardWeight = 1,
      this.backwardWeight = 1}) {
    reset();
  }
  factory SegmentIteratorNeighboursBidirectionnal.fromValues(
      {@required PolyLine line,
      @required int increment,
      bool forwardFirst = true,
      int forwardWeight = 1,
      int backwardWeight = 1}) {
    return SegmentIteratorNeighboursBidirectionnal(
        forward: SegmentIteratorNeighboursUnidirectionnal(
            increment: increment, line: line),
        backward: SegmentIteratorNeighboursUnidirectionnal(
            increment: -1 * increment, line: line),
        backwardWeight: backwardWeight,
        forwardFirst: forwardFirst,
        forwardWeight: forwardWeight);
  }
  String toString() {
    return "[SegmentIteratorNeighboursBidirectionnal,hasNext=$hasNext,\n\tbackward=${backward.toString()},\n\tforward=${forward.toString()}]";
  }

  void reset() {
    forward.reset();
    backward.reset();
    forwardFirst ? _setForward() : _setBackward();
  }

  void prepareNext(VectorTime movement, int currentIndex) {
    forward.prepareNext(movement, currentIndex);
    backward.prepareNext(movement, currentIndex - 1);
  }

  void _setBackward() {
    _current = backward;
    _counter = backwardWeight;
  }

  void _setForward() {
    _current = forward;
    _counter = forwardWeight;
  }

  void _resetCounterIfNeeded() {
    if (_counter == 0) {
      _current == forward ? _setBackward() : _setForward();
    }
  }

  bool get hasNext {
    return forward.hasNext || backward.hasNext;
  }

  VectorIndexed next() {
    if (forward.hasNext && backward.hasNext) {
      _resetCounterIfNeeded();
      _counter--;
    } else if (forward.hasNext) {
      _current = forward;
    } else {
      //backward must have next
      _current = backward;
    }
    return _current.next();
  }
}

SegmentIterator defaultSegmentIterator(
    {@required PolyLine line,
    @required TransportType type,
    //skip the first (because we could be at the end of the segment in previous movement)
    int nbOfDistanceSkipped = 1,
    int increment = 1}) {
  //
  double defaultMaxDistanceMeters = 20 * 1000.0;
  switch (type) {
    case TransportType.Bike: //20km/h (2km/6min)
      defaultMaxDistanceMeters = 2 * 1000.0;
      break;
    case TransportType.Walk: //8km/h (800m/6min)
      defaultMaxDistanceMeters = 1 * 1000.0;
      break;
    case TransportType.Car: //20km (150km/h => 15km/6min)
    default:
      break;
  }
  //lookup forward and backward
  return SegmentIteratorNeighboursBidirectionnal(
      forwardFirst: true,
      forwardWeight: 3, //forward 3 times faster
      forward: SegmentIteratorNeighboursLimitDistance(
        defaultMaxDistanceMeters: defaultMaxDistanceMeters,
        nbOfDistanceSkipped: nbOfDistanceSkipped,
        adaptative: true, //adapt distance to previous
        adaptativeRatio: 10,
        child: SegmentIteratorNeighboursUnidirectionnal(
            increment: increment, line: line),
      ),
      backward: SegmentIteratorNeighboursLimitDistance(
          nbOfDistanceSkipped: nbOfDistanceSkipped,
          defaultMaxDistanceMeters: defaultMaxDistanceMeters,
          adaptative: true, //adapt distance to previous
          child: SegmentIteratorNeighboursUnidirectionnal(
              increment: -increment, line: line)));
}
