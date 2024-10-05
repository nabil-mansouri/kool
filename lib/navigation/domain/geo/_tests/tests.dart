import 'package:flutter_test/flutter_test.dart';
import 'geometry.dart';
import 'nearest_point.dart';
import 'segment_iterator.dart';
import 'segment_approver.dart';
import 'segment_finder.dart';
import 'simulator.dart';

unitTestGeo() {
  group("[Geo]", () {
   unitTestGeometry();
    unitTestNearestSegment();
    unitTestSegmentApprover();
    unitTestSegmentIterator();
    unitTestSegmentFinder();
    unitTestSimulator();
  });
}
