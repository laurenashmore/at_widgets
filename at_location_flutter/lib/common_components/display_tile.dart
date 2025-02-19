import 'dart:typed_data';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/service/contact_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'contacts_initial.dart';

class DisplayTile extends StatefulWidget {
  final String? title, semiTitle, subTitle, atsignCreator, invitedBy;
  final int? number;
  final Widget? action;
  final bool showName, showRetry;
  final Function? onRetryTapped;
  DisplayTile(
      {required this.title,
      required this.atsignCreator,
      required this.subTitle,
      this.semiTitle,
      this.invitedBy,
      this.number,
      this.showName = false,
      this.action,
      this.showRetry = false,
      this.onRetryTapped});

  @override
  _DisplayTileState createState() => _DisplayTileState();
}

class _DisplayTileState extends State<DisplayTile> {
  Uint8List? image;
  AtContact? contact;
  AtContactsImpl? atContact;
  String? name;
  @override
  void initState() {
    super.initState();
    getEventCreator();
  }

  // ignore: always_declare_return_types
  getEventCreator() async {
    var contact = await getAtSignDetails(widget.atsignCreator);
    // ignore: unnecessary_null_comparison
    if (contact != null) {
      if (contact.tags != null && contact.tags!['image'] != null) {
        List<int> intList = contact.tags!['image'].cast<int>();
        if (mounted) {
          setState(() {
            image = Uint8List.fromList(intList);
            if (widget.showName) name = contact.tags!['name'].toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 15, 10.5),
      child: Row(
        children: [
          Stack(
            children: [
              (image != null)
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.all(Radius.circular(30.toFont)),
                      child: Image.memory(
                        image!,
                        width: 50.toFont,
                        height: 50.toFont,
                        fit: BoxFit.fill,
                      ),
                    )
                  : widget.atsignCreator != null
                      ? ContactInitial(initials: widget.atsignCreator)
                      : SizedBox(),
              widget.number != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        height: 28.toFont,
                        width: 28.toFont,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0.toFont),
                            color: AllColors().BLUE),
                        child: Text(
                          '+${widget.number}',
                          style: CustomTextStyles().black10,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Column(
                mainAxisAlignment: (widget.subTitle == null)
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? widget.title!,
                    style: CustomTextStyles().black14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  widget.semiTitle != null
                      ? Text(
                          widget.semiTitle!,
                          style: (widget.semiTitle == 'Action required' ||
                                      widget.semiTitle == 'Request declined') ||
                                  (widget.semiTitle == 'Cancelled')
                              ? CustomTextStyles().LIGHT_RED12
                              : CustomTextStyles().darkGrey12,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 3,
                  ),
                  (widget.subTitle != null)
                      ? Text(
                          widget.subTitle!,
                          style: CustomTextStyles().darkGrey12,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox(),
                  widget.invitedBy != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(widget.invitedBy!,
                              style: CustomTextStyles().grey14),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
          widget.showRetry
              ? InkWell(
                  onTap: () {
                    widget.onRetryTapped!();
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: AllColors().LIGHT_RED, fontSize: 14.toFont),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : SizedBox(),
          widget.action ?? SizedBox(),
        ],
      ),
    );
  }
}
