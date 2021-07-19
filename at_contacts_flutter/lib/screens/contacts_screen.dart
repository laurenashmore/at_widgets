/// The screen which is exposed from the library for displaying, adding, selecting and deleting Contacts,
/// takes in @param [context] to get the app context
/// @param [currentAtsing] to get the contacts for the give [atSign]
/// @param [selectedList] is a callback function to return back the selected list from the screen to the app
/// @param [asSelectionScreen] toggles between the selection type screen of to display the contacts

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:at_contacts_flutter/widgets/bottom_sheet.dart';
import 'package:at_contacts_flutter/widgets/custom_list_tile.dart';
import 'package:at_contacts_flutter/widgets/custom_search_field.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:at_contacts_flutter/widgets/horizontal_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../services/contact_service.dart';

class ContactsScreen extends StatefulWidget {
  final BuildContext? context;
  final ValueChanged<List<AtContact?>>? selectedList;
  final bool asSelectionScreen;
  final bool asSingleSelectionScreen;
  final Function? saveGroup, onSendIconPressed;

  const ContactsScreen(
      {Key? key,
      this.selectedList,
      this.context,
      this.asSelectionScreen = false,
      this.asSingleSelectionScreen = false,
      this.saveGroup,
      this.onSendIconPressed})
      : super(key: key);
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String searchText = '';
  ContactService? _contactService;
  bool deletingContact = false;
  bool blockingContact = false;
  bool errorOcurred = false;
  List<AtContact?> selectedList = [];

  @override
  void initState() {
    _contactService = ContactService();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      var _result = await _contactService!.fetchContacts();
      print('$_result = true');
      if (_result == null) {
        print('_result = true');
        if (mounted) {
          setState(() {
            errorOcurred = true;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      bottomSheet: (widget.asSelectionScreen)
          ? (widget.asSingleSelectionScreen)
              ? Container(height: 0)
              : CustomBottomSheet(
                  onPressed: () {
                    Navigator.pop(widget.context!);
                    if (widget.saveGroup != null) {
                      ContactService().clearAtSigns();
                    }
                  },
                  selectedList: (List<AtContact?>? s) {
                    if (widget.selectedList != null) {
                      widget.selectedList!(s!);
                    }
                    if (widget.saveGroup != null) {
                      widget.saveGroup!();
                    }
                  },
                )
          : Container(
              height: 0,
            ),
      appBar: CustomAppBar(
        showBackButton: true,
        showTitle: true,
        showLeadingIcon: true,
        titleText: TextStrings().contacts,
        onLeadingIconPressed: () {
          setState(() {
            if (widget.asSelectionScreen) {
              ContactService().clearAtSigns();
              selectedList = [];
              widget.selectedList!(selectedList);
            }
          });
        },
        onTrailingIconPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddContactDialog(),
          );
        },
        // ignore: unnecessary_null_comparison
        showTrailingIcon: widget.asSelectionScreen == null ||
                widget.asSelectionScreen == false
            ? true
            : false,
        trailingIcon: Center(
          child: Icon(
            Icons.add,
            color: ColorConstants.fontPrimary,
          ),
        ),
      ),
      body: errorOcurred
          ? ErrorScreen()
          : Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.toWidth, vertical: 16.toHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ContactSearchField(
                    TextStrings().searchContact,
                    (text) => setState(() {
                      searchText = text;
                    }),
                  ),
                  SizedBox(
                    height: 15.toHeight,
                  ),
                  ///
                  ///
                  /// List of contacts: (?)
                  (widget.asSelectionScreen)
                      ? (widget.asSingleSelectionScreen)
                          ? Container()
                          : HorizontalCircularList()
                      : Container(),
                  Expanded(
                      child: StreamBuilder<List<AtContact?>>(
                    stream: _contactService!.contactStream,
                    initialData: _contactService!.contactList,
                    builder: (context, snapshot) {
                      if ((snapshot.connectionState ==
                          ConnectionState.waiting)) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if ((snapshot.data == null || snapshot.data!.isEmpty)) {
                          return Center(
                            child: Text(TextStrings().noContacts),
                          );
                        } else {
                          var _filteredList = <AtContact?>[];
                          snapshot.data!.forEach((c) {
                            if (c!.atSign!
                                .toUpperCase()
                                .contains(searchText.toUpperCase())) {
                              _filteredList.add(c);
                            }
                          });
                          if (_filteredList.isEmpty) {
                            return Center(
                              child: Text(TextStrings().noContactsFound),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.toHeight),
                            itemCount: 27,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, alphabetIndex) {
                              var contactsForAlphabet = <AtContact?>[];
                              var currentChar =
                                  String.fromCharCode(alphabetIndex + 65)
                                      .toUpperCase();
                              if (alphabetIndex == 26) {
                                currentChar = 'Others';
                                _filteredList.forEach((c) {
                                  if (int.tryParse(c!.atSign![1]) != null) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                              } else {
                                _filteredList.forEach((c) {
                                  if (c!.atSign![1].toUpperCase() ==
                                      currentChar) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                              }

                              if (contactsForAlphabet.isEmpty) {
                                return Container();
                              }
                              return Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currentChar,
                                          style: TextStyle(
                                            color: ColorConstants.blueText,
                                            fontSize: 16.toFont,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.toWidth),
                                        Expanded(
                                          child: Divider(
                                            color: ColorConstants.dividerColor
                                                .withOpacity(0.2),
                                            height: 1.toHeight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListView.separated(
                                        itemCount: contactsForAlphabet.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        separatorBuilder: (context, _) =>
                                            Divider(
                                              color: ColorConstants.dividerColor
                                                  .withOpacity(0.2),
                                              height: 1.toHeight,
                                            ),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Slidable(
                                              actionPane:
                                                  SlidableDrawerActionPane(),
                                              actionExtentRatio: 0.25,
                                              secondaryActions: <Widget>[
                                                IconSlideAction(
                                                  caption: TextStrings().block,
                                                  color: ColorConstants
                                                      .inputFieldColor,
                                                  icon: Icons.block,
                                                  onTap: () async {
                                                    setState(() {
                                                      blockingContact = true;
                                                    });
                                                    // ignore: unawaited_futures
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Center(
                                                          child: Text(
                                                              TextStrings()
                                                                  .blockContact),
                                                        ),
                                                        content: Container(
                                                          height: 100.toHeight,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    await _contactService!
                                                        .blockUnblockContact(
                                                            contact:
                                                                contactsForAlphabet[
                                                                    index]!,
                                                            blockAction: true);
                                                    setState(() {
                                                      blockingContact = false;
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                ),
                                                IconSlideAction(
                                                  caption: TextStrings().delete,
                                                  color: Colors.red,
                                                  icon: Icons.delete,
                                                  onTap: () async {
                                                    setState(() {
                                                      deletingContact = true;
                                                    });
                                                    // ignore: unawaited_futures
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Center(
                                                          child: Text(
                                                              TextStrings()
                                                                  .deleteContact),
                                                        ),
                                                        content: Container(
                                                          height: 100.toHeight,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    await _contactService!
                                                        .deleteAtSign(
                                                            atSign:
                                                                contactsForAlphabet[
                                                                        index]!
                                                                    .atSign!);
                                                    setState(() {
                                                      deletingContact = false;
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                ),
                                              ],
                                              child: Container(
                                                child: CustomListTile(
                                                  contactService:
                                                      _contactService,
                                                  onTap: () {},
                                                  asSelectionTile:
                                                      widget.asSelectionScreen,
                                                  asSingleSelectionTile: widget
                                                      .asSingleSelectionScreen,
                                                  contact: contactsForAlphabet[
                                                      index],
                                                  selectedList: (s) {
                                                    selectedList = s!;
                                                    widget.selectedList!(
                                                        selectedList);
                                                  },
                                                  onTrailingPressed:
                                                      widget.onSendIconPressed,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      }
                    },
                  ))
                ],
              ),
            ),
    );
  }
}
