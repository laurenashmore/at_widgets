import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

import 'colors.dart';

class CustomTextStyles {
  CustomTextStyles._();
  static final CustomTextStyles _instance = CustomTextStyles._();
  factory CustomTextStyles() => _instance;

  TextStyle blackPlayfairDisplay38 = TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: 38.toFont,
      color: AllColors().Black);

  TextStyle greyLabel14 = TextStyle(
    color: AllColors().GREY_LABEL,
    fontSize: 14.toFont,
  );

  TextStyle greyLabel12 = TextStyle(
    color: AllColors().GREY_LABEL,
    fontSize: 12.toFont,
  );

  TextStyle lightGreyLabel12 = TextStyle(
    color: AllColors().LIGHT_GREY_LABEL,
    fontSize: 12.toFont,
  );
  TextStyle black16 = TextStyle(
    color: AllColors().Black,
    fontSize: 16.toFont,
  );

  TextStyle black16bold = TextStyle(
    color: AllColors().Black,
    fontSize: 16.toFont,
    fontWeight: FontWeight.w700,
  );
  TextStyle black12 = TextStyle(
    color: AllColors().Black,
    fontSize: 12.toFont,
  );

  TextStyle white15 = TextStyle(
    color: AllColors().WHITE,
    fontSize: 15.toFont,
  );

  TextStyle black18 = TextStyle(
    color: AllColors().Black,
    fontSize: 18.toFont,
    fontWeight: FontWeight.w700,
  );

  TextStyle black10 = TextStyle(
    color: AllColors().Black,
    fontSize: 10.toFont,
  );

  TextStyle LIGHT_RED16 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 16.toFont,
  );

  TextStyle LIGHT_RED12 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 12.toFont,
  );

  TextStyle LIGHT_RED14 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 14.toFont,
  );

  TextStyle darkGrey15 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 15.toFont,
  );

  TextStyle darkGrey10 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 10.toFont,
  );

  TextStyle LIGHT_RED18 = TextStyle(
    color: AllColors().LIGHT_RED,
    fontSize: 18.toFont,
  );

  TextStyle darkGrey13 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 13.toFont,
  );

  TextStyle darkGrey14 =
      TextStyle(color: AllColors().DARK_GREY, fontSize: 14.toFont);

  TextStyle boldLabel16 = TextStyle(
    fontSize: 16.toFont,
  );

  TextStyle black14 = TextStyle(
    color: AllColors().Black,
    fontSize: 14.toFont,
  );

  TextStyle darkGrey16 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 16.toFont,
  );

  TextStyle grey16 = TextStyle(
    color: AllColors().GREY,
    fontSize: 16.toFont,
  );

  TextStyle darkGrey12 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 12.toFont,
  );

  TextStyle grey12 = TextStyle(
    color: AllColors().GREY,
    fontSize: 12.toFont,
  );

  TextStyle red12 = TextStyle(
    color: AllColors().RED,
    fontSize: 12.toFont,
  );

  TextStyle grey14 = TextStyle(
    color: AllColors().GREY,
    fontSize: 14.toFont,
  );

  TextStyle whiteBold16 = TextStyle(
    color: Colors.white,
    fontSize: 16.toFont,
    fontWeight: FontWeight.w700,
  );
}
