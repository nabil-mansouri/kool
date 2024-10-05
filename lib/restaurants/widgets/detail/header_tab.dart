import 'package:flutter/material.dart';
import 'view_model.dart';
import 'package:food/commons/indexed_listview/indexed_listview.dart';

class ProductCategoryChip extends StatelessWidget {
  final String text;
  final int position;
  final bool first;
  final bool last;
  final RestaurantDetailViewModel model;
  ProductCategoryChip(this.model, this.position, {this.first, this.last})
      : text = model.categories[position].category;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: first ? 16 : 8, right: last ? 16 : 8),
        //update on each event
        child: StreamBuilder<int>(
            initialData: model.categorySelected,
            //update when body or head update...
            stream: model.categoryHeadEmitter
                .mergeWith([model.categorySelectFromHeadChanged]),
            builder: (context, snap) {
              bool selected = position == snap.data;
              return ChoiceChip(
                backgroundColor: Colors.transparent,
                selectedColor: Colors.black,
                label: Text(text.toUpperCase(),
                    style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontSize: 16)),
                selected: selected,
                onSelected: (bool selected) {
                  if (selected) {
                    model.setSelectedCategoryFromHead(position);
                  }
                },
              );
            }));
  }
}

class RestaurantTabScrollView extends StatefulWidget with PreferredSizeWidget {
  final RestaurantDetailViewModel model;
  RestaurantTabScrollView(this.model);
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  createState() => _TabScrollView();
}

class _TabScrollView extends State<RestaurantTabScrollView> {
  RestaurantDetailViewModel get widgetModel => this.widget.model;

  build(context) {
    double width = MediaQuery.of(context).size.width;
    List<String> names = widgetModel.categories.map((f) => f.category).toList();
    return SizedBox(
        width: width,
        height: kToolbarHeight,
        child: Container(
            child: IndexedListView.builder(
          onJumpToIndex: widgetModel.categoryHeadEmitter,
          position: IndexedListPosition.nearStart,
          options: IndexedListViewOptions(
            padding: EdgeInsets.only(bottom: 8),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return ProductCategoryChip(widgetModel, index,
                  first: index == 0, last: index == names.length - 1);
            },
            itemCount: widgetModel.categories.length,
          ),
        )));
  }
}
