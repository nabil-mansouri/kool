import 'contract.dart';
import 'firebase_impl.dart';
import 'mock_impl.dart';

export 'contract.dart';
export 'firebase_impl.dart';
export 'firebase_daos.dart';
export 'mock_impl.dart';

ProductService _service;
const _MOCK = false;
setProductService(ProductService restoService) {
  _service = restoService;
}

ProductService getProductService() {
  if (_service == null) {
    _service = _MOCK ? ProductServiceMock() : ProductServiceFirebase();
  }
  return _service;
}
