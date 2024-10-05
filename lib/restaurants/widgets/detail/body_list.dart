import 'package:flutter/material.dart';
import 'body_row.dart';
import 'view_model.dart';
import 'package:food/commerce/commerce.dart';
import 'package:food/commons/indexed_view_tracker/indexed_view_tracker.dart';

class DetailProductList extends StatelessWidget {
  final RestaurantDetailViewModel detailModel;
  DetailProductList(this.detailModel);

  buildRow(BuildContext context, RestaurantDetailRowViewModel row, {Key key}) {
    if (row.isRestaurantInfo) {
      return RestaurantInfoRowWidget(this.detailModel.current);
    } else if (row.isCategory) {
      return ProductCategoryRowWidget(row, key: key);
    } else if (row.isProduct) {
      if (row.firstProduct) {
        return ProductRowSelectable(row.product, key: key, onTap: () {
          detailModel.selectProduct(context, row.product);
        });
      } else {
        return Column(key: key, children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 0)),
          ProductRowSelectable(row.product, key: key, onTap: () {
            detailModel.selectProduct(context, row.product);
          })
        ]);
      }
    } else {
      return Container(key: key);
    }
  }

  build(context) {
    //
    var rows = this.detailModel.rows;
    //var width = MediaQuery.of(context).size.width;
    if (rows.length == 0) {
      return Center(child: CircularProgressIndicator());
    }
    var scrollable = Scrollable.of(context);
    return IndexedListViewTracked.builder(
      onJumpToIndex: detailModel.categoryBodyEmitter,
      onIndexReached: (index) {
        detailModel.onIndexedReached(index);
      },
      scrollController: scrollable?.widget?.controller,
      onNotification: detailModel.onNotification,
      position: IndexedListPosition.start,
      options: IndexedListViewOptions(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20),
        itemBuilder: (context, index) {
          return this.buildRow(context, rows[index]);
        },
        itemCount: rows.length,
      ),
    );
  }
}
