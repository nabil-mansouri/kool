import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import '../geo.dart';

unitTestSegmentIterator() {
  final leCreusot = Point(46.8, 4.4333);
  final point1 = leCreusot.transform(1, 0);
  final point2 = point1.transform(2, 20);
  final point3 = point2.transform(3, 40);
  final point4 = point3.transform(4, 60);
  final point5 = point4.transform(5, -80);
  final point6 = point5.transform(6, -100);
  final point7 = point6.transform(7, -120);
  final point8 = point7.transform(8, -120);
  final point9 = point8.transform(9, -140);
  final point10 = point9.transform(10, -160);
  final line = PolyLine([
    leCreusot,
    point1,
    point2,
    point3,
    point4,
    point5,
    point6,
    point7,
    point8,
    point9,
    point10
  ]);
  final bigLine = PolyLine([
    leCreusot,
    leCreusot.transform(1000, 0),
    leCreusot.transform(2000, 0),
    leCreusot.transform(3000, 0),
    leCreusot.transform(34000, 0)
  ]);
  _iterate(SegmentIterator it, {VectorTime movement, int startAtIndex = 0}) {
    it.prepareNext(movement, startAtIndex);
    final List<VectorIndexed> results = [];
    while (it.hasNext && results.length < 100) {
      final _last = it.next();
      results.add(_last);
    }
    return results;
  }

  _checkIndexes(List<VectorIndexed> vectors, List<int> indexes,
      {bool indexOnly = false}) {
    for (int i = 0; i < indexes.length; i++) {
      final lineIndex = indexes[i];
      expect(vectors[i].index, equals(lineIndex));
      if (!indexOnly) {
        expect(vectors[i].vector.distanceInMeter,
            equals(line.vectors[lineIndex].distanceInMeter),
            reason:
                "Vector at index $i should match vector in polyline $lineIndex");
      }
    }
  }

  group('[SegmentIterator]', () {
    test('should iterate forward', () {
      final it =
          SegmentIteratorNeighboursUnidirectionnal(increment: 1, line: line);
      final res = _iterate(it, startAtIndex: 0);
      expect(res.length, equals(10));
    });
    test('should iterate forward increment 2', () {
      final it =
          SegmentIteratorNeighboursUnidirectionnal(increment: 2, line: line);
      final res = _iterate(it, startAtIndex: 0);
      expect(res.length, equals(5));
    });
    test('should iterate forward from middle', () {
      final it =
          SegmentIteratorNeighboursUnidirectionnal(increment: 1, line: line);
      final res = _iterate(it, startAtIndex: 5);
      expect(res.length, equals(5));
    });

    test('should iterate forward and backward from middle', () {
      final it = SegmentIteratorNeighboursBidirectionnal.fromValues(
          increment: 1, line: line);
      final res = _iterate(it, startAtIndex: 5);
      _checkIndexes(res, [5, 4, 6, 3, 7, 2, 8, 1, 9, 0]);
    });
    test('should iterate forward and backward from end', () {
      final it = SegmentIteratorNeighboursBidirectionnal.fromValues(
          increment: 1, line: line);
      final res = _iterate(it, startAtIndex: 8);
      _checkIndexes(res, [8, 7, 9, 6, 5, 4, 3, 2, 1, 0]);
    });
    test('should iterate forward and backward from begining', () {
      final it = SegmentIteratorNeighboursBidirectionnal.fromValues(
          increment: 1, line: line);
      final res = _iterate(it, startAtIndex: 1);
      _checkIndexes(res, [1, 0, 2, 3, 4, 5, 6, 7, 8, 9]);
    });
    test('should iterate forward and backward from midle with 3/2 ratio', () {
      final it = SegmentIteratorNeighboursBidirectionnal.fromValues(
          increment: 1, line: line, forwardWeight: 3, backwardWeight: 2);
      final res = _iterate(it, startAtIndex: 5);
      _checkIndexes(res, [5, 6, 7, 4, 3, 8, 9, 2, 1, 0]);
    });

    test(
        'should iterate forward and backward from midle with 3/2 ratio backward first',
        () {
      final it = SegmentIteratorNeighboursBidirectionnal.fromValues(
          increment: 1,
          line: line,
          forwardWeight: 3,
          backwardWeight: 2,
          forwardFirst: false);
      final res = _iterate(it, startAtIndex: 5);
      _checkIndexes(res, [4, 3, 5, 6, 7, 2, 1, 8, 9, 0]);
    });
    test(
        'should iterate forward and backward from midle with 3/2 ratio backward first and step 2',
        () {
      final it = SegmentIteratorNeighboursBidirectionnal.fromValues(
          increment: 2,
          line: line,
          forwardWeight: 3,
          backwardWeight: 2,
          forwardFirst: false);
      final res = _iterate(it, startAtIndex: 5);
      _checkIndexes(res, [4, 2, 5, 7, 9, 0]);
    });
    test('should iterate until distance', () {
      final child =
          SegmentIteratorNeighboursUnidirectionnal(increment: 1, line: line);
      final it = SegmentIteratorNeighboursLimitDistance(
          nbOfDistanceSkipped: 0, //dont Skip any distance
          child: child,
          defaultMaxDistanceMeters: 10);
      //1+2+3+4
      final res = _iterate(it);
      expect(res.length, equals(5));
      _checkIndexes(res, [0, 1, 2, 3, 4]);
    });
    test('should iterate until distance adaptative', () {
      final child =
          SegmentIteratorNeighboursUnidirectionnal(increment: 1, line: line);
      final it = SegmentIteratorNeighboursLimitDistance(
          child: child,
          nbOfDistanceSkipped: 0, //dont Skip any distance
          defaultMaxDistanceMeters: 10,
          adaptativeRatio: 10,
          adaptative: true);
      //adaptive = 2m*10
      final vector = VectorTime(
          leCreusot, leCreusot.transform(2, 0), Duration(seconds: 1));
      //1+2+3+4=10 +5+6=21
      final res = _iterate(it, movement: vector);
      expect(res.length, equals(6));
      _checkIndexes(res, [0, 1, 2, 3, 4, 5]);
    });
    test('should iterate until default because adaptive is null', () {
      final child =
          SegmentIteratorNeighboursUnidirectionnal(increment: 1, line: line);
      final it = SegmentIteratorNeighboursLimitDistance(
          child: child,
          nbOfDistanceSkipped: 0, //dont Skip any distance
          defaultMaxDistanceMeters: 25,
          adaptativeRatio: 10,
          adaptative: true);
      //adaptive = 0
      final vector = VectorTime(leCreusot, leCreusot, Duration(seconds: 1));
      final res = _iterate(it, movement: vector);
      expect(res.length, equals(7));
      _checkIndexes(res, [0, 1, 2, 3, 4, 5, 6]);
    });
    test(
        'should iterate with default iterator with adaptative (1.5*10 foreach side)',
        () {
      final it = defaultSegmentIterator(
          nbOfDistanceSkipped: 0, //dont Skip any distance
          line: line,
          increment: 1,
          type: TransportType.Car);
      //adaptative 1.5*10m (foreach direction)
      final vector = VectorTime(
          leCreusot, leCreusot.transform(1.5, 0), Duration(seconds: 1));
      final res = _iterate(it, startAtIndex: 5, movement: vector);
      expect(res.length, equals(8));
      _checkIndexes(res, [5, 6, 7, 4, 3, 2, 1, 0]);
    });
    test(
        'should iterate with default iterator with adaptative (1*10 foreach side)',
        () {
      final it = defaultSegmentIterator(
          nbOfDistanceSkipped: 0, //dont Skip any distance
          line: line,
          increment: 1,
          type: TransportType.Car);
      //adaptative 1*10m (foreach direction)
      final vector = VectorTime(
          leCreusot, leCreusot.transform(1, 0), Duration(seconds: 1));
      final res = _iterate(it, startAtIndex: 5, movement: vector);
      expect(res.length, equals(5));
      _checkIndexes(res, [5, 6, 4, 3, 2]);
    });
    test(
        'should iterate and limit distance with adaptative ratio and big vectors',
        () {
      final it = defaultSegmentIterator(
          line: bigLine, increment: 1, type: TransportType.Car);
      final endOfVector1 = leCreusot.transform(990, 0);
      //go at 990/1000m of first vector and go forward 11 me after
      var vector = VectorTime(
          endOfVector1, endOfVector1.transform(11, 0), Duration(seconds: 1));
      final res = _iterate(it, startAtIndex: 0, movement: vector);
      expect(res.length, equals(2));
      _checkIndexes(res, [0, 1], indexOnly: true);
    });
    test(
        'should iterate and limit distance with adaptative ratio and big vectors reverse',
        () {
      final it = defaultSegmentIterator(
          line: bigLine, increment: 1, type: TransportType.Car);
      final endOfVector1 = leCreusot.transform(23010, 0);
      //go at 10/1000m of fourth vector and back 11meter behind
      var vector = VectorTime(
          endOfVector1, endOfVector1.transform(-11, 0), Duration(seconds: 1));
      final res = _iterate(it, startAtIndex: 3, movement: vector);
      expect(res.length, equals(3));
      //start with current, then back (skip), and back again
      _checkIndexes(res, [3, 2, 1], indexOnly: true);
    });
  });
}
