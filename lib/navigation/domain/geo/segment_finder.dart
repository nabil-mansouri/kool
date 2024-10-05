import 'package:optional/optional.dart';
import 'package:meta/meta.dart';
import 'segment_approver.dart';
import 'segment_iterator.dart';
import 'nearest_point.dart';
import 'geometry.dart';

abstract class SegmentMandator {
  void reset();
  void prepareNext(VectorTime movement);
  bool shouldContinue(NearestPointOnSegment near, {@required bool approved});
  Optional<NearestPointOnSegment> selectResult(
      List<NearestPointOnSegment> approved);
}

class SegmentMandatorAcceptFirst implements SegmentMandator {
  void reset() {}
  void prepareNext(VectorTime movement) {}
  bool shouldContinue(NearestPointOnSegment near, {@required bool approved}) {
    return !approved;
  }

  Optional<NearestPointOnSegment> selectResult(
      List<NearestPointOnSegment> approved) {
    return Optional.ofNullable(approved.isNotEmpty ? approved.first : null);
  }
}

abstract class SegmentFinder {
  Optional<NearestPointOnSegment> next(VectorTime movement);
  bool get hasPrevSegment;
  bool get hasCurrentSegment;
  Optional<Vector> get prevSegment;
  Optional<Vector> get currentSegment;
  int get nbTimes;
  bool get hasGoneBack;
  bool get hasGoneForward;
  bool get isInPlace;
}

class SegmentFinderDefault implements SegmentFinder {
  final SegmentApprover approver;
  final SegmentIterator iterator;
  final SegmentMandator mandator;
  final PolyLine line;
  //cache
  int _nbTimes = 0;
  VectorIndexed _lastVectorIndex;
  Optional<NearestPointOnSegment> _prevAccept = Optional.empty();
  Optional<NearestPointOnSegment> _curAccept = Optional.empty();
  SegmentFinderDefault(
      {@required this.approver,
      @required this.iterator,
      @required this.mandator,
      @required this.line}) {
    reset();
  }
  void reset() {
    this.iterator.reset();
    this.approver.reset();
    this.mandator.reset();
  }

  Optional<NearestPointOnSegment> next(VectorTime movement) {
    this.iterator.prepareNext(movement, _lastVectorIndex?.index ?? 0);
    this.approver.prepareNext(movement);
    this.mandator.prepareNext(movement);
    List<NearestPointOnSegment> results = [];
    while (this.iterator.hasNext) {
      _lastVectorIndex = this.iterator.next();
      NearestPointOnSegment nearResult = NearestPointOnSegment.fromSegment(
          _lastVectorIndex.vector, _lastVectorIndex.index, movement.end);
      bool approved = this.approver.approve(nearResult);
      if (approved) {
        results.add(nearResult);
      }
      if (!mandator.shouldContinue(nearResult, approved: approved)) {
        break;
      }
    }
    _prevAccept = _curAccept;
    _curAccept = mandator.selectResult(results);
    _nbTimes++;
    return _curAccept;
  }

  bool get hasPrevSegment => _prevAccept.isPresent;
  bool get hasCurrentSegment => _curAccept.isPresent;
  Optional<Vector> get prevSegment => _prevAccept.map((t) => t.startToEnd);
  Optional<Vector> get currentSegment => _curAccept.map((t) => t.startToEnd);
  int get nbTimes => _nbTimes;
  bool get hasGoneBack {
    if (hasPrevSegment && hasCurrentSegment) {
      return _curAccept.value.segmentIndex < _prevAccept.value.segmentIndex;
    }
    return false;
  }

  bool get isInPlace {
    if (hasPrevSegment && hasCurrentSegment) {
      return _curAccept.value.segmentIndex == _prevAccept.value.segmentIndex;
    }
    return false;
  }

  bool get hasGoneForward {
    if (hasPrevSegment && hasCurrentSegment) {
      return _curAccept.value.segmentIndex > _prevAccept.value.segmentIndex;
    }
    //first time go forward
    return !hasPrevSegment && hasCurrentSegment;
  }

  String toString() {
    return "SegmentFinder[founded=$hasCurrentSegment,index=${_curAccept.orElse(null)?.segmentIndex},isForward=$hasGoneForward,isBackward=$hasGoneBack,iterator=${iterator.toString()}]";
  }
}

SegmentFinder defaultSegmentFinder({
  @required PolyLine line,
  @required TransportType type,
}) {
  return SegmentFinderDefault(
      line: line,
      approver: defaultSegmentApprover(),
      iterator: defaultSegmentIterator(line: line, type: type),
      mandator: defaultSegmentMandator());
}

SegmentMandator defaultSegmentMandator() {
  return SegmentMandatorAcceptFirst();
}
