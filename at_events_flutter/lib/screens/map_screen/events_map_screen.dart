import 'dart:typed_data';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_events_flutter/common_components/floating_icon.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/distance_calculate.dart';
import 'package:at_location_flutter/event_show_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'events_collapsed_content.dart';

/// TODO: Sometimes updateEventdataFromList is called consecutively multiple times, so location data is not displayed consistently
class EventsMapScreenData {
  EventsMapScreenData._();
  static final EventsMapScreenData _instance = EventsMapScreenData._();
  factory EventsMapScreenData() => _instance;

  ValueNotifier<EventNotificationModel?>? eventNotifier;
  late List<HybridModel> markers;
  late List<String?> exitedAtSigns;
  int count = 0;

  void moveToEventScreen(EventNotificationModel _eventNotificationModel) async {
    markers = [];
    exitedAtSigns = [];
    _calculateExitedAtsigns(_eventNotificationModel);
    eventNotifier = ValueNotifier(_eventNotificationModel);
    markers.add(addVenueMarker(_eventNotificationModel));

    // ignore: unawaited_futures
    Navigator.push(
      AtEventNotificationListener().navKey!.currentContext!,
      MaterialPageRoute(
        builder: (context) => _EventsMapScreen(),
      ),
    );

    // markers =
    var _hybridModelList =
        await _calculateHybridModelList(_eventNotificationModel);
    _hybridModelList.forEach((element) {
      markers.add(element);
    });
    eventNotifier!.notifyListeners();
  }

  void _calculateExitedAtsigns(EventNotificationModel _event) {
    _event.group!.members!.forEach((element) {
      if ((element.tags!['isExited']) && (!element.tags!['isAccepted'])) {
        exitedAtSigns.add(element.atSign);
      }
    });
  }

  List<List<EventKeyLocationModel>> _listOfLists = [];
  bool _updating = false;
  void updateEventdataFromList(List<EventKeyLocationModel> _list) async {
    _listOfLists.add(_list);
    if (!_updating) {
      _startUpdating();
    }
  }

  void _startUpdating() async {
    _updating = true;
    for (var i = 0; i < _listOfLists.length; i++) {
      var _obj = _listOfLists.removeAt(0);
      await _updateEventdataFromList(_obj);
    }
    _updating = false;
  }

  Future<void> _updateEventdataFromList(
      List<EventKeyLocationModel> _list) async {
    count++;
    print('count++ $count');
    if (eventNotifier != null) {
      for (var i = 0; i < _list.length; i++) {
        if (_list[i].eventNotificationModel!.key == eventNotifier!.value!.key) {
          exitedAtSigns = [];
          _calculateExitedAtsigns(_list[i].eventNotificationModel!);

          markers = [];

          markers.add(addVenueMarker(_list[i].eventNotificationModel!));

          var _hybridModelList =
              await _calculateHybridModelList(_list[i].eventNotificationModel!);
          _hybridModelList.forEach((element) {
            markers.add(element);
          });

          eventNotifier!.value = _list[i].eventNotificationModel;
          eventNotifier!.notifyListeners();

          count--;
          print('count-- $count');
          break;
        }
      }
    }
  }

  HybridModel addVenueMarker(EventNotificationModel _event) {
    var _eventHybridModel = HybridModel(
        displayName: _event.venue!.label,
        latLng: LatLng(_event.venue!.latitude!, _event.venue!.longitude!),
        eta: '?',
        image: null);
    _eventHybridModel.marker = buildMarker(_eventHybridModel);
    return _eventHybridModel;
  }

  Future<List<HybridModel>> _calculateHybridModelList(
      EventNotificationModel _event) async {
    var _tempMarkersList = <HybridModel>[];

    /// Event creator
    if (_event.lat != null && _event.long != null) {
      var user = HybridModel(
          displayName: _event.atsignCreator,
          latLng: LatLng(_event.lat!, _event.long!),
          eta: '?',
          image: null);
      user.eta = await _calculateEta(
          user, LatLng(_event.venue!.latitude!, _event.venue!.longitude!));
      user.image = await (_imageOfAtsign(_event.atsignCreator!) as FutureOr<Uint8List?>);
      user.marker = buildMarker(user);
      _tempMarkersList.add(user);
    }

    /// Event members
    await Future.forEach(_event.group!.members!, (dynamic element) async {
      print(
          '${element.atSign}, ${element.tags['lat']}, ${element.tags['long']}');
      if ((element.tags['lat'] != null) && (element.tags['long'] != null)) {
        var _user = HybridModel(
            displayName: element.atSign,
            latLng: LatLng(element.tags['lat'], element.tags['long']),
            eta: '?',
            image: null);
        _user.eta = await _calculateEta(
            _user, LatLng(_event.venue!.latitude!, _event.venue!.longitude!));

        _user.image = await (_imageOfAtsign(element.atSign) as FutureOr<Uint8List?>);
        _user.marker = buildMarker(_user);

        _tempMarkersList.add(_user);
      }
    });

    return _tempMarkersList;
  }

  Future<String> _calculateEta(HybridModel user, LatLng etaFrom) async {
    try {
      var _res = await DistanceCalculate().calculateETA(etaFrom, user.latLng!);
      return _res;
    } catch (e) {
      print('Error in _calculateEta $e');
      return '?';
    }
  }

  Future<dynamic> _imageOfAtsign(String _atsign) async {
    var contact = await getAtSignDetails(_atsign);
    if (contact != null) {
      if (contact.tags != null && contact.tags!['image'] != null) {
        List<int> intList = contact.tags!['image'].cast<int>();
        return Uint8List.fromList(intList);
      }
    }

    return null;
  }

  void dispose() {
    eventNotifier = null;
    markers = [];
    exitedAtSigns = [];
  }
}

class _EventsMapScreen extends StatefulWidget {
  const _EventsMapScreen({Key? key}) : super(key: key);

  @override
  _EventsMapScreenState createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<_EventsMapScreen> {
  final PanelController pc = PanelController();
  List _previousMembersSharingLocation = [];

  @override
  void dispose() {
    EventsMapScreenData().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: ValueListenableBuilder(
            valueListenable: EventsMapScreenData().eventNotifier!,
            builder: (BuildContext context, EventNotificationModel? _event,
                Widget? child) {
              print('ValueListenableBuilder called');
              var _locationList = EventsMapScreenData().markers;
              var _membersSharingLocation = [];
              _locationList.forEach((e) => {
                    if ((e.displayName !=
                            AtEventNotificationListener().currentAtSign) &&
                        (e.displayName != _event!.venue!.label))
                      {_membersSharingLocation.add(e.displayName)}
                  });

              print('_locationList $_locationList');

              if (((_previousMembersSharingLocation.isEmpty) ||
                      (_previousMembersSharingLocation !=
                          _membersSharingLocation)) &&
                  (_membersSharingLocation.isNotEmpty)) {
                Future.delayed(Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(_membersSharingLocation.length > 1
                          ? '${_listToString(_membersSharingLocation)} are sharing their locations'
                          : '${_listToString(_membersSharingLocation)} is sharing their location')));
                  _previousMembersSharingLocation = _membersSharingLocation;
                });
              }

              return Stack(
                children: [
                  eventShowLocation(_locationList,
                      LatLng(_event!.venue!.latitude!, _event.venue!.longitude!)),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: FloatingIcon(
                      icon: Icons.arrow_back,
                      isTopLeft: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SlidingUpPanel(
                    controller: pc,
                    minHeight: 205.toHeight,
                    maxHeight: 431.toHeight,
                    panel: eventsCollapsedContent(_event),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String? _listToString(List _strings) {
    String? _res;
    if (_strings.isNotEmpty) {
      _res = _strings[0];
    }

    _strings.sublist(1).forEach((element) {
      _res = '$_res, $element';
    });

    return _res;
  }
}
