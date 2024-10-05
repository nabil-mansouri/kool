import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/multiflow/multiflow.dart';

class CustomInputWidget extends StatelessWidget {
  final FormFieldController controller;
  final String hintText;
  final bool autocorrect;
  final int maxLines;
  final bool autofocus;
  final String labelText;
  final Widget suffixIcon;
  final TextInputType keyboardType;
  final double fontSize;
  final EdgeInsets contentPadding;
  CustomInputWidget(
      {@required this.controller,
      @required this.hintText,
      this.maxLines = 1,
      this.fontSize = 14,
      this.suffixIcon,
      this.autofocus = false,
      this.autocorrect = false,
      this.contentPadding,
      this.labelText,
      this.keyboardType});
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      autofocus: autofocus,
      autocorrect: autocorrect,
      focusNode: this.controller?.focusNode,
      controller: this.controller?.controller,
      keyboardType: this.keyboardType,
      inputFormatters: this.controller?.formatters,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: fontSize, color: Colors.black),
      decoration: InputDecoration(
          suffixIcon: this.suffixIcon,
          labelText: this.labelText,
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
          hintText: this.hintText),
    );
  }
}
