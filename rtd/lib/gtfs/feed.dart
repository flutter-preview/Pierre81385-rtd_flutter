import 'package:flutter/material.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:http/http.dart' as http;
import 'package:rtd/gtfs/map.dart';
import '../data_sets/route_data.dart';
import '../data_sets/stop_data.dart';
import '../data_sets/trip_data.dart';

class RTDFeed extends StatefulWidget {
  const RTDFeed({required this.vehicle, super.key});
  final String vehicle;

  @override
  State<RTDFeed> createState() => _RTDFeedState();
}

class _RTDFeedState extends State<RTDFeed> {
  late List<FeedEntity> alerts = [];
  late List<FeedEntity> trips = [];
  late List<FeedEntity> vehicles = [];

  late GlobalKey<ScaffoldState> _scaffoldKey;
  late String stopSelected;

  final status = ["Incoming at", "Stopped at", "In transit to"];

  final snack = const SnackBar(
    content: Text('Data Refreshed'),
  );

  void AlertFeed() async {
    final url = Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/Alerts.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Alerts: ${feedMessage.entity.length}.');

      setState(() {
        alerts = feedMessage.entity;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void TripFeed() async {
    final url =
        Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/TripUpdate.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Trips Found: ${feedMessage.entity.length}.');

      setState(() {
        trips = feedMessage.entity;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void VehicaleFeed() async {
    final url = Uri.parse(
        'https://www.rtd-denver.com/files/gtfs-rt/VehiclePosition.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Vehicles Found: ${feedMessage.entity.length}.');

      setState(() {
        vehicles = feedMessage.entity;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Widget _buildPopupDialog(BuildContext context, list) {
    List<FeedEntity> thisList = list;

    return AlertDialog(
      title: const Text('Service Alerts'),
      content: list.length > 0
          ? Container(
              width: double.maxFinite,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: thisList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      isThreeLine: true,
                      title: Column(
                        children: [
                          Text(thisList[index]
                              .alert
                              .descriptionText
                              .translation[0]
                              .text
                              .toString()),
                          thisList[index].alert.activePeriod[0].start.toInt() >
                                  0
                              ? Text(
                                  "Starting ${DateTime.fromMillisecondsSinceEpoch(thisList[index].alert.activePeriod[0].start.toInt() * 1000).toString()}")
                              : SizedBox(),
                        ],
                      ),
                      subtitle: Text(thisList[index]
                          .alert
                          .headerText
                          .translation[0]
                          .text
                          .toString()),
                    );
                  }),
            )
          : Text('There are no service alerts at this time.'),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  void initState() {
    AlertFeed();
    VehicaleFeed();
    TripFeed();
    _scaffoldKey = GlobalKey();
    stopSelected = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(
              Duration(seconds: 1),
              () {
                /// adding elements in list after [1 seconds] delay
                /// to mimic network call
                ///
                /// Remember: [setState] is necessary so that
                /// build method will run again otherwise
                /// list will not show all elements
                setState(() {
                  AlertFeed();
                  VehicaleFeed();
                  TripFeed();
                });

                // showing snackbar
                ScaffoldMessenger.of(context).showSnackBar(snack);
              },
            );
          },
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: vehicles.length,
              itemBuilder: (BuildContext context, int index) {
                List<TripUpdate_StopTimeUpdate> stops = [];
                print(
                    "vehicle tripid = ${vehicles[index].vehicle.trip.tripId}");
                int tripIndex = trips.indexWhere((element) =>
                    element.tripUpdate.trip.tripId ==
                    vehicles[index].vehicle.trip.tripId);
                if (tripIndex == -1) {
                  print('no trip data');
                } else {
                  for (var i = 0;
                      i <= trips[tripIndex].tripUpdate.stopTimeUpdate.length;
                      i++) {
                    stops = trips[tripIndex].tripUpdate.stopTimeUpdate.toList();
                  }
                }

                //get route data of the selected train/bus
                return routeData[
                            vehicles[index].vehicle.trip.routeId.toString()] ==
                        null
                    ? const SizedBox()
                    : widget.vehicle == "select"
                        ? const SizedBox()
                        : routeData[vehicles[index]
                                        .vehicle
                                        .trip
                                        .routeId
                                        .toString()]!["route_short_name"]
                                    .toString() ==
                                widget.vehicle
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius
                                                    .only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            isThreeLine: true,
                                            //name of the route selected
                                            leading: IconButton(
                                              onPressed: () {
                                                //popup for station list here
                                                // showDialog(
                                                //   context: context,
                                                //   builder:
                                                //       (BuildContext context) =>
                                                //           _buildPopupDialog(
                                                //               context,
                                                //               vehicles[index]
                                                //                   .vehicle
                                                //                   .trip
                                                //                   .routeId),
                                                // );
                                              },
                                              icon:
                                                  Icon(Icons.schedule_outlined),
                                            ),
                                            //descriptive name of the route
                                            title: Text(
                                                "${routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_short_name"].toString()} Line heading to ${tripData[vehicles[index].vehicle.trip.routeId.toString()]?["trip_headsign"].toString()} ${status[vehicles[index].vehicle.currentStatus.value].toUpperCase()} ${stopData[vehicles[index].vehicle.stopId]!["stop_name"]}"),
                                            //the current location of the selected train/bus
                                            trailing: IconButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      MapView(
                                                                        lat: vehicles[index]
                                                                            .vehicle
                                                                            .position
                                                                            .latitude,
                                                                        long: vehicles[index]
                                                                            .vehicle
                                                                            .position
                                                                            .longitude,
                                                                        line: routeData[vehicles[index].vehicle.trip.routeId.toString()] ==
                                                                                null
                                                                            ? "line unknown"
                                                                            : routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_short_name"].toString(),
                                                                        vehicleId: vehicles[index]
                                                                            .vehicle
                                                                            .vehicle
                                                                            .id,
                                                                        status: vehicles[index]
                                                                            .vehicle
                                                                            .currentStatus
                                                                            .toString(),
                                                                        route: routeData[vehicles[index].vehicle.trip.routeId.toString()] ==
                                                                                null
                                                                            ? "route name unknown"
                                                                            : routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_long_name"].toString(),
                                                                      )));
                                                },
                                                icon: const Icon(
                                                    Icons.place_outlined)),
                                            //route direction information & current status of movement
                                            subtitle: Text(
                                                "Status update on ${DateTime.fromMillisecondsSinceEpoch(vehicles[index].vehicle.timestamp.toInt() * 1000).toString()}"),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                          onPressed: () {
                                            if (stopSelected == "") {
                                              setState(() {
                                                stopSelected = stopData[
                                                            vehicles[index]
                                                                .vehicle
                                                                .stopId]![
                                                        "stop_name"]
                                                    .toString();
                                              });
                                            } else {
                                              setState(() {
                                                stopSelected = "";
                                              });
                                            }
                                          },
                                          child: stopSelected ==
                                                  stopData[vehicles[index]
                                                          .vehicle
                                                          .stopId]!["stop_name"]
                                                      .toString()
                                              ? Text("Hide Stop Information")
                                              : Text("Show Stop Information")),
                                      stopSelected ==
                                              stopData[vehicles[index]
                                                      .vehicle
                                                      .stopId]!["stop_name"]
                                                  .toString()
                                          ? Container(
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  // physics:
                                                  //     const AlwaysScrollableScrollPhysics(),
                                                  itemCount: stops.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    List<FeedEntity>
                                                        thisAlertsList = [];

                                                    for (var i = 0;
                                                        i <= alerts.length - 1;
                                                        i++) {
                                                      var informedEntities =
                                                          alerts[i]
                                                              .alert
                                                              .informedEntity;
                                                      for (var entity
                                                          in informedEntities) {
                                                        if (entity.stopId ==
                                                            stops[index]
                                                                .stopId) {
                                                          thisAlertsList
                                                              .add(alerts[i]);

                                                          print(thisAlertsList
                                                              .toString());
                                                        }
                                                      }
                                                    }

                                                    return ListTile(
                                                      isThreeLine: true,
                                                      leading: IconButton(
                                                        onPressed: () {
                                                          //popup for station list here
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  _buildPopupDialog(
                                                                      context,
                                                                      thisAlertsList));
                                                        },
                                                        icon: thisAlertsList
                                                                    .length >
                                                                0
                                                            ? Icon(Icons
                                                                .railway_alert)
                                                            : Icon(null),
                                                      ),
                                                      title: Center(
                                                        child: Text(stopData[
                                                                    stops[index]
                                                                        .stopId]![
                                                                "stop_name"]
                                                            .toString()),
                                                      ),
                                                      subtitle: Column(
                                                        children: [
                                                          Text(
                                                              "Arrives at ${DateTime.fromMillisecondsSinceEpoch(stops[index].arrival.time.toInt() * 1000).toString()}"),
                                                          Text(
                                                              "Departs at ${DateTime.fromMillisecondsSinceEpoch(stops[index].departure.time.toInt() * 1000).toString()}")
                                                        ],
                                                      ),
                                                    );
                                                  }))
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox();
              }),
        ),
      ),
    );
  }
}
