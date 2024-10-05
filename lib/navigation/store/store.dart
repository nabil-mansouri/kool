import 'package:food/multiflow/multiflow.dart';
import 'package:meta/meta.dart';
export 'routes.dart';

@immutable
class GeoNavigationState {}

class GeoNavigationStore extends Store<GeoNavigationState> {
  GeoNavigationStore() : super(GeoNavigationState());
}
