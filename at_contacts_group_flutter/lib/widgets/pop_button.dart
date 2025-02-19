import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;
  PopButton({required this.label, this.textStyle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Text(label, style: textStyle ?? CustomTextStyles().LIGHT_RED16)),
    );
  }
}
