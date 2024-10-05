import 'package:food/multiflow/multiflow.dart';
import '../../domain/domain.dart';
import "../../store/store.dart";

class RestaurantPaymentViewModel extends AbstractModel<RestaurantState> {
  bool ready = false;
  RestaurantModel current;
  RestaurantDetailModel detail;
  //
  bool refresh(RestaurantState state) {
    var changed = false;
    //
    if (this.current != state.current) {
      this.current = state.current;
      changed = true;
    }
    //
    if (state.currentDetail != this.detail) {
      this.detail = state.currentDetail;
      changed = true;
    }
    //MUST BE AT THE END
    var isReady = (detail != null && current != null);
    if (ready != isReady) {
      this.ready = isReady;
      changed = true;
    }
    return changed;
  }
}
