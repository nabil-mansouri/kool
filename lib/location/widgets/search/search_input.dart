import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:food/commons/custom_input.dart';

typedef OnCancel = void Function();

class LocationSearchInput extends StatelessWidget {
  final String hint;
  final OnCancel onCancel;
  final FormFieldController controller;
  LocationSearchInput(
      {@required this.controller, @required this.onCancel, this.hint});
  build(context) {
    return PhysicalModel(
        color: Colors.white,
        elevation: 4,
        child: Container(
          child: Row(children: [
            IconButton(icon: Icon(Icons.close), onPressed: () => onCancel()),
            Expanded(
                child: CustomInputWidget(
              autofocus: true,
              controller: controller,
              autocorrect: false,
              maxLines: 1,
              fontSize: 16,
              contentPadding:
                  EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 18),
              keyboardType: TextInputType.text,
              suffixIcon: Icon(Icons.search, color: Colors.black),
              hintText: hint,
            ))
          ]),
        ));
  }
}

class LocationFakeSearchInput extends StatelessWidget {
  final GestureTapCallback onTap;
  final String placeholder;
  LocationFakeSearchInput({@required this.placeholder, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.search),
      title: Text(placeholder, style: TextStyle(color: Colors.black54)),
    );
  }
}
