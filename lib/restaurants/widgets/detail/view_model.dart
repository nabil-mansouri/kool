import '../../store/store.dart';
import '../../domain/domain.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';
import 'package:food/commerce/commerce.dart';
import 'package:food/location/location.dart';

class RestaurantDetailRowViewModel {
  ProductModel product;
  String category;
  bool firstRow;
  bool lastRow;
  bool firstProduct;
  bool isRestaurantInfo;
  RestaurantDetailRowViewModel(
      {this.product,
      this.category,
      this.firstRow,
      this.lastRow,
      this.firstProduct,
      this.isRestaurantInfo = false});
  get isProduct => this.product != null;
  get isCategory => this.category != null;
}

class RestaurantPlanningRowViewModel {
  String day;
  String address;
  String rangeHour;
  RestaurantPlanningRowViewModel({this.day, this.address, this.rangeHour});
  get isDay => this.day != null;
  get isAddress => this.address != null;
  get isRangeHour => this.rangeHour != null;
}

mixin _RestaurantDetailViewModel$Category {
  int categorySelected = 0;
  List<RestaurantDetailRowViewModel> rows = [];
  List<RestaurantDetailRowViewModel> categories = [];
  //
  final Subject<int> categoryBodyEmitter = PublishSubject();
  final Subject<int> categoryHeadEmitter = PublishSubject();
  final Subject<int> categorySelectFromHeadChanged = PublishSubject();
  final Subject<ScrollNotification> onNotification = PublishSubject();
  _categoryChanged(int index) {
    if (this.categorySelected != index) {
      return true;
    }
    return false;
  }

  _fromCategoryToRowsIndex(int index) {
    var cat = this.categories[index];
    var newIndex = this.rows.indexOf(cat);
    return newIndex < 0 ? 0 : newIndex;
  }

  _fromRowsToCategoryIndex(int index) {
    RestaurantDetailRowViewModel cat;
    for (int i = 0; i <= index && i < this.rows.length; i++) {
      if (this.rows[i].isCategory) {
        cat = this.rows[i];
      }
    }
    if (cat == null) {
      return 0;
    }
    var newIdex = this.categories.indexOf(cat);
    return newIdex < 0 ? 0 : newIdex;
  }

  setSelectedCategoryFromHead(int index) {
    if (_categoryChanged(index)) {
      this.categorySelected = index;
      var rowIndex = _fromCategoryToRowsIndex(index);
      categoryBodyEmitter.add(rowIndex);
      categorySelectFromHeadChanged.add(index);
    }
  }

  dispose() {
    categoryHeadEmitter.close();
    categorySelectFromHeadChanged.close();
    categoryBodyEmitter.close();
    onNotification.close();
  }

  onIndexedReached(int index) {
    var catIndex = _fromRowsToCategoryIndex(index);
    if (_categoryChanged(catIndex)) {
      this.categorySelected = catIndex;
      categoryHeadEmitter.add(catIndex);
    }
  }
}

class RestaurantDetailViewModel extends AbstractModel<RestaurantState>
    with _RestaurantDetailViewModel$Category {
  bool ready = false;
  RestaurantModel current;
  RestaurantDetailModel detail;
  //
  GeoPosition position;
  List<RestaurantDetailRowViewModel> categories = [];
  List<RestaurantDetailRowViewModel> rows = [];
  List<RestaurantPlanningRowViewModel> planning = [];

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
      if (detail != null) {
        _updateDetail();
        _updateFirstFlags();
      }
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

  _updateDetail() {
    this.rows = [];
    this.categories = [];
    this.planning = [];
    this.position = GeoPosition(latitude: 17, longitude: 17); //TODO dynamic
    //
    this.rows.add(RestaurantDetailRowViewModel(isRestaurantInfo: true));
    //categories
    var categories = List.from(detail.categories);
    categories.sort((c1, c2) => c1.position.compareTo(c2.position));
    //rows
    List<ProductCategory> copyCategories = List<ProductCategory>.from(
        categories); //copy to avoid concurrent update
    copyCategories.forEach((category) {
      var products = detail.products
          .where((test) => test.categories.contains(category.id));
      if (products.length > 0) {
        var cat = RestaurantDetailRowViewModel(category: category.name);
        this.rows.add(cat);
        this.categories.add(cat);
        products.forEach((product) {
          var row = RestaurantDetailRowViewModel(product: product);
          this.rows.add(row);
        });
      }
    });
    //add any product that dont have category
    Set<String> categoriesSet = detail.categories.map((c) => c.id).toSet();
    var products = detail.products.where((test) =>
        Set.from(test.categories).intersection(categoriesSet).length == 0);
    if (products.length > 0) {
      var cat = RestaurantDetailRowViewModel(category: "Autres");
      this.rows.add(cat);
      this.categories.add(cat);
    }
    products.forEach((product) {
      var row = RestaurantDetailRowViewModel(product: product);
      this.rows.add(row);
    });
    //sort slot by day and open minute
    detail.slots.sort((a1, a2) {
      if (a1.day == a2.day) {
        return a1.openMinute.compareTo(a2.closeMinute);
      } else {
        return a1.day.compareTo(a2.day);
      }
    });
    //remove overlapping slots
    detail.slots.removeWhere((slot) {
      var founded = detail.slots.where((slot2) =>
          slot2 != slot &&
          slot2.day == slot.day &&
          slot2.allTheDay != null &&
          slot2.allTheDay);
      return founded.length > 0;
    });
    //convert
    this.planning.add(RestaurantPlanningRowViewModel(
        address: "7 Rue Jean Jaures 71200 Le Creusot"));
    var previousDay;
    detail.slots.forEach((slot) {
      //set days
      if (slot.dayFormat != previousDay) {
        this.planning.add(RestaurantPlanningRowViewModel(day: slot.dayFormat));
        previousDay = slot.dayFormat;
      }
      //set slots
      this.planning.add(RestaurantPlanningRowViewModel(
          rangeHour: "${slot.openFormat} - ${slot.closeFormat}"));
    });
  }

  _updateFirstFlags() {
    RestaurantDetailRowViewModel first, last;
    String previousCategory;
    bool catChanged;
    //ignore restaurant info
    this.rows.where((row) => !row.isRestaurantInfo).forEach((row) {
      //reset
      row.firstRow = row.lastRow = row.firstProduct = false;
      //detect first and last element
      if (first == null) first = row;
      last = row;
      //detect when category changed
      if (row.isCategory) {
        if (previousCategory == null || row.category != previousCategory) {
          catChanged = true;
        } else {
          catChanged = false;
        }
      }
      //detect first product of category
      if (row.isProduct) {
        if (catChanged) {
          row.firstProduct = true;
          catChanged = false;
        }
      }
    });
    if (first != null) first.firstRow = true;
    if (last != null) last.lastRow = true;
  }

  selectProduct(BuildContext context, ProductModel model) {
    this
        .getStore<RestaurantStore>(context, RestaurantStore)
        .selectProduct(model);
  }
  @override
  onDispose() {
    this.dispose();
    return super.onDispose();
  }
}
