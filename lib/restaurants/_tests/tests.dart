import 'package:test/test.dart' show group;
import 'service.dart';
import 'workflow.dart';
import 'demo.dart';
import 'utils.dart';

testRestaurants() {
  //demo();
  //return;
  group("[Restaurant]", () {
    RestaurantTestUtils testUtils = RestaurantTestUtils();
    startServiceTest(testUtils);
    startWorkflowTest(testUtils);
  });
}
