import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'view_model.dart';
import 'custom_picker.dart';

class RestaurantDatePickerWidget extends StatelessWidget {
  final SearchViewModel model;
  RestaurantDatePickerWidget(this.model);
  @override
  Widget build(BuildContext context) {
    final double kItemHeight = 28;
    final double fontSize = kItemHeight / 2;
    final listHeight = 4 * kItemHeight;
    final days = model.dateModel.formattedDays
        .map((t) => Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Text(t,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: fontSize))))
        .toList();
    return WillPopScope(
        onWillPop: () {
          model.cancelDate();
          return Future.value(true);
        },
        child: GestureDetector(
            onTap: () {}, //ignore tap
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Choisir la date de livraison",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                                height: listHeight,
                                child: CustomPicker(
                                  offAxisFraction: -0.5,
                                  magnification: 1.1,
                                  useMagnifier: true,
                                  backgroundColor: Colors.white,
                                  itemExtent: kItemHeight,
                                  onSelectedItemChanged: (i) {
                                    model.selectDay(i);
                                  },
                                  children: days,
                                ))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Flexible(
                            flex: 1,
                            child: SizedBox(
                                height: listHeight,
                                child: StreamBuilder(
                                    stream:
                                        model.dateModel.onHourChanged.stream,
                                    builder: (context, snap) {
                                      final hours = model
                                          .dateModel.formattedHours
                                          .map((t) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 7),
                                              child: Text(t,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontSize: fontSize))))
                                          .toList();
                                      return CustomPicker(
                                        scrollController:
                                            model.dateModel.controller,
                                        offAxisFraction: 0.5,
                                        magnification: 1.1,
                                        useMagnifier: false,
                                        backgroundColor: Colors.white,
                                        itemExtent: kItemHeight,
                                        onSelectedItemChanged: (i) {
                                          model.selectHour(i);
                                        },
                                        children: hours,
                                      );
                                    })))
                      ],
                    ),
                    Flexible(
                        child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            child: Text(
                              "VALIDER MON CHOIX",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              model.submitDate(context);
                            }))
                  ],
                ))));
  }
}
