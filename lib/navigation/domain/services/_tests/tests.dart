import 'package:flutter_test/flutter_test.dart';
import 'navigation_infos.dart';
import 'navigation_restarter.dart';
import 'service.mapkit.dart';
import 'navigation.dart';

unitTestNavigationService() {
  group("[Services]", () {
    //unitTestNavigationInfos();
    //unitTestNavigationRestarter();
    //dont flood mapkit
    //unitTestMapkitService();
    unitTestNavigation();
  });
}
