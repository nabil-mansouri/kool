//query by tags "array_contains"
//query by important tags "array_contains"
//query by price > <
//query by name start with < > + lowercase
//sort by price
//sort by popularity
//sort by rating
//sort by position

import 'contract.dart';
import 'firebase_impl.dart';
import 'mock_impl.dart';

export 'contract.dart';
export 'firebase_impl.dart';
export 'mock_impl.dart';

RestaurantService _service;
const _MOCK = false;
setRestaurantService(RestaurantService restoService) {
  _service = restoService;
}

RestaurantService getRestaurantService() {
  if (_service == null) {
    _service = _MOCK ? RestaurantServiceMock() : RestaurantServiceFirebase();
  }
  return _service;
}
