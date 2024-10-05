import 'service_mapkit.dart';
import 'contract.dart';
export '../geo/geo.dart';
export "navigation_infos/navigation_infos.dart";
export 'navigation_restarter.dart';
export 'navigation.dart';
export 'contract.dart';
export 'service_mapkit.dart';
export 'service_mock.dart';
export 'dump_nav.dart';

NavigationService _navigationService;
setDefaultNavigationService(NavigationService service) {
  _navigationService = service;
}

defaultNavigationService() {
  if (_navigationService != null) return _navigationService;
  return NavigationServiceMapKit.init();
}

//start navigation
//compute direction from 2 points
//compute distance to nearest step (firs?second...)
//set the first step
//listen position changes
//foreach change
//compute distance to next step
//compute distance to previous step
//if distance increase from previous and next step => wait Xmeter to recompute
//compute travel time
//compute tilt from previous and current position
