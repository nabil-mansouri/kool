import 'contract.dart';
import 'service_impl.dart';

export 'contract.dart';
export 'service_impl.dart';

LocationService _service;
//const _MOCK = false;
setLocationService(LocationService restoService) {
  _service = restoService;
}

LocationService getLocationService() {
  if (_service == null) {
    _service = LocationServiceImpl();
  }
  return _service;
}
