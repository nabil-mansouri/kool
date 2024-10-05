import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import '../../store/store.dart';
import '../../domain/domain.dart';

class SelectionRowViewModel {
  //both
  final bool unique;
  //header
  final bool headerMandatory;
  final String headerTitle;
  final String headerSubtitle;
  final int headerMin;
  final int headerMax;
  int headerCount = 0;
  //product
  final ProductItemModel productItem;
  final String productPrice;
  final String productOptionId;
  final int productPriceCents;
  final String productName;
  final SelectionRowViewModel parent;
  bool _selected = false;
  //description
  final String description;
  SelectionRowViewModel(
      {this.headerMandatory = false,
      this.headerMin,
      this.headerMax,
      this.headerSubtitle,
      this.headerTitle,
      this.unique = false,
      this.parent,
      this.productItem,
      this.productOptionId,
      this.productName,
      this.productPrice,
      this.productPriceCents,
      this.description});
  factory SelectionRowViewModel.fromGroup(ProductGroupModel group) {
    String subtitle;
    int min = 0, max = 1;
    final isMinEmpty = group.minSelection == null || group.minSelection == 0;
    if (!isMinEmpty && group.maxSelection != null) {
      min = group.minSelection;
      max = group.maxSelection;
      if (group.minSelection == group.maxSelection) {
        subtitle = "Choisissez ${group.maxSelection}";
      } else {
        subtitle =
            "Choisissez entre ${group.minSelection} et ${group.maxSelection}";
      }
    } else if (!isMinEmpty) {
      min = group.minSelection;
      subtitle = "Choisissez au moins ${group.maxSelection}";
    } else if (group.maxSelection != null) {
      max = group.maxSelection;
      subtitle = "Choisissez jusqu'à ${group.maxSelection}";
    }
    //
    bool unique = false;
    if (min == 1 && max == 1) {
      unique = true;
    }
    //
    return SelectionRowViewModel(
        headerMin: min,
        headerMax: max,
        unique: unique,
        headerMandatory: group.mandatory != null && group.mandatory,
        headerTitle: group.name,
        headerSubtitle: subtitle);
  }
  factory SelectionRowViewModel.fromProduct(
      SelectionRowViewModel parent, ProductItemModel item) {
    return SelectionRowViewModel(
        parent: parent,
        unique: parent.unique,
        productOptionId: item.id,
        productItem: item,
        productName: item.name,
        productPriceCents: item.priceCents,
        productPrice: item.price);
  }
  bool get isHeader => this.headerTitle != null;
  bool get isDescription => this.description != null;
  bool get hasHeaderSubtitle => this.headerSubtitle != null;
  bool get hasPrice => this.productPriceCents != null;
  bool get isProduct => this.productName != null;
  bool get selected => this._selected;
  set selected(b) {
    if (b != _selected) {
      if (b)
        parent?.headerCount++;
      else
        parent?.headerCount--;
    }
    _selected = b;
  }
}

class SelectionViewModel extends AbstractModel<CartState> {
  ProductModel product;
  int quantity = 1;
  bool productLoading = false;
  bool productLoadFailed = false;
  List<SelectionRowViewModel> rows = [];
  List<ProductGroupModel> groups = [];
  CartItem originalCartItem;
  TextEditingController commentController = TextEditingController();
  
  onDispose() {
    commentController.dispose();
    super.onDispose();
  }

  bool refresh(CartState state) {
    bool changed = false;
    if (state.productLoading != this.productLoading) {
      this.productLoading = state.productLoading;
      changed = true;
    }
    if (state.productLoadFailed != this.productLoadFailed) {
      this.productLoadFailed = state.productLoadFailed;
      changed = true;
    }
    if (state.detail.product != this.product) {
      this.product = state.detail.product;
      changed = true;
    }
    if (state.detail.groups != this.groups) {
      this.groups = state.detail.groups;
      _updateRows();
      _updateFromCartItem();
      changed = true;
    }
    if (state.currentItem != this.originalCartItem) {
      this.originalCartItem = state.currentItem;
      _updateFromCartItem();
      changed = true;
    }
    return changed;
  }

  submit(BuildContext context) {
    if (canSubmit) {
      if (quantity == 0) {
        this.remove(context);
        return;
      }
      List<ProductItemModel> items = [];
      for (SelectionRowViewModel row in this.rows) {
        if (row.isProduct && row.selected) {
          items.add(row.productItem);
        }
      }
      if (isEditing) {
        this.getStore<CartStore>(context, CartStore).updateCartItem(
            comment: this.commentController.text,
            items: items,
            product: this.product,
            quantity: this.quantity,
            oldCartItem: this.originalCartItem);
      } else {
        this.getStore<CartStore>(context, CartStore).addCartItem(
            comment: this.commentController.text,
            items: items,
            product: this.product,
            quantity: this.quantity);
      }
    }
  }

  remove(BuildContext context) {
    // can delete only if from cartitem
    if (this.originalCartItem != null) {
      this
          .getStore<CartStore>(context, CartStore)
          .removeCartItem(this.originalCartItem);
    }
  }

  get isEditing {
    return this.originalCartItem != null;
  }

  canDecrement() {
    if (isEditing) {
      return this.quantity > 0;
    } else {
      return this.quantity > 1;
    }
  }

  incrementQuantity() {
    this.updateQuantity(this.quantity + 1);
  }

  decrementQuantity() {
    if (this.canDecrement()) {
      this.updateQuantity(this.quantity - 1);
    }
  }

  updateQuantity(int qty) {
    if (qty == 0 && this.originalCartItem != null) {
      this.quantity = qty;
      notifyListeners();
      return;
    }
    //cannot set 0 if not already cartitem
    if (qty > 0) {
      this.quantity = qty;
      notifyListeners();
    }
  }

  updateRow(SelectionRowViewModel row, bool selected) {
    if (row.isProduct && row.selected != selected) {
      final parent = row.parent;
      if (selected) {
        //add
        final List<SelectionRowViewModel> rowsSelectedInSameCategory = this
            .rows
            .where(
                (test) => test.parent == parent && test != row && test.selected)
            .toList();
        //if group is a uniq selection unset all others
        if (parent.unique) {
          rowsSelectedInSameCategory.forEach((f) => f.selected = false);
        }
        final alreadySelectedCount = rowsSelectedInSameCategory.length;
        if (alreadySelectedCount < parent.headerMax) {
          row.selected = selected;
          notifyListeners();
        }
      } else {
        //remove
        row.selected = selected;
        notifyListeners();
      }
    }
  }

  String get submitText {
    if (quantity == 0) {
      return "SUPPRIMER DU PANIER";
    } else if (isEditing) {
      return "METTRE A JOUR LE PANIER $totalFormat";
    } else {
      return "AJOUTER $quantity AU PANIER $totalFormat";
    }
  }

  bool get canDecrease => this.quantity > 0;
  bool get canSubmit {
    bool canSubmit = true;
    this.rows.where((test) => test.isHeader).forEach((test) {
      if (test.headerCount < test.headerMin ||
          test.headerCount > test.headerMax) {
        canSubmit = false;
      }
    });
    return canSubmit && this.product.available;
  }

  int get totalCents {
    int amount = this.product?.priceCents ?? 0;
    this.rows.forEach((row) {
      if (row.isProduct && row.selected) {
        amount += row.productPriceCents ?? 0;
      }
    });
    return amount * this.quantity;
  }

  String get totalFormat {
    return formatCurrency.format(totalCents / 100);
  }

  _updateFromCartItem() {
    if (this.originalCartItem != null) {
      final optionIds =
          this.originalCartItem.details.map((d) => d.optionId).toSet();
      for (SelectionRowViewModel row in this.rows) {
        if (row.isProduct && optionIds.contains(row.productOptionId)) {
          this.updateRow(row, true);
        }
      }
      this.quantity = this.originalCartItem.quantity;
    } else {
      this.quantity = 1;
      this.commentController.text = "";
    }
  }

  _updateRows() {
    this.rows = [];
    if (this.groups != null) {
      for (ProductGroupModel group in this.groups) {
        final rowGroup = SelectionRowViewModel.fromGroup(group);
        this.rows.add(rowGroup);
        for (ProductItemModel item in group.items) {
          this.rows.add(SelectionRowViewModel.fromProduct(rowGroup, item));
        }
      }
    }
  }
}
