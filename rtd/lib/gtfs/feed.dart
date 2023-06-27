import 'package:flutter/material.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:http/http.dart' as http;
import 'package:rtd/gtfs/map.dart';
import '../data_sets/route_data.dart';
import '../data_sets/stop_data.dart';

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

  final snack = SnackBar(
    content: const Text('Page Refreshed'),
  );

  void AlertFeed() async {
    final url = Uri.parse('https://www.rtd-denver.com/files/gtfs-rt/Alerts.pb');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final feedMessage = FeedMessage.fromBuffer(response.bodyBytes);

      print('Number of Alerts: ${feedMessage.entity.length}.');

      alerts = feedMessage.entity;
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

      trips = feedMessage.entity;
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

      vehicles = feedMessage.entity;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    AlertFeed();
    VehicaleFeed();
    TripFeed();
    _scaffoldKey = GlobalKey();
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
                                  child: ListTile(
                                    isThreeLine: true,
                                    //name of the route selected
                                    leading: Text(routeData[vehicles[index]
                                                .vehicle
                                                .trip
                                                .routeId
                                                .toString()] ==
                                            null
                                        ? "no route data"
                                        : routeData[vehicles[index]
                                                    .vehicle
                                                    .trip
                                                    .routeId
                                                    .toString()]![
                                                "route_short_name"]
                                            .toString()),
                                    //descriptive name of the route
                                    title: Text(routeData[vehicles[index]
                                                .vehicle
                                                .trip
                                                .routeId
                                                .toString()] ==
                                            null
                                        ? "no route data"
                                        : routeData[vehicles[index]
                                                .vehicle
                                                .trip
                                                .routeId
                                                .toString()]!["route_long_name"]
                                            .toString()),
                                    //the current location of the selected train/bus
                                    trailing: IconButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushReplacement(
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) => MapView(
                                                                lat: vehicles[
                                                                        index]
                                                                    .vehicle
                                                                    .position
                                                                    .latitude,
                                                                long: vehicles[
                                                                        index]
                                                                    .vehicle
                                                                    .position
                                                                    .longitude,
                                                                line: routeData[vehicles[index]
                                                                            .vehicle
                                                                            .trip
                                                                            .routeId
                                                                            .toString()] ==
                                                                        null
                                                                    ? "line unknown"
                                                                    : routeData[vehicles[index]
                                                                            .vehicle
                                                                            .trip
                                                                            .routeId
                                                                            .toString()]!["route_short_name"]
                                                                        .toString(),
                                                                vehicleId:
                                                                    vehicles[
                                                                            index]
                                                                        .vehicle
                                                                        .vehicle
                                                                        .id,
                                                                status: vehicles[
                                                                        index]
                                                                    .vehicle
                                                                    .currentStatus
                                                                    .toString(),
                                                                route: routeData[vehicles[index]
                                                                            .vehicle
                                                                            .trip
                                                                            .routeId
                                                                            .toString()] ==
                                                                        null
                                                                    ? "route name unknown"
                                                                    : routeData[vehicles[index]
                                                                            .vehicle
                                                                            .trip
                                                                            .routeId
                                                                            .toString()]!["route_long_name"]
                                                                        .toString(),
                                                              )));
                                        },
                                        icon: const Icon(Icons.location_on)),
                                    //route direction information & current status of movement
                                    subtitle: Text(
                                        "${routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_desc"]} and is ${vehicles[index].vehicle.currentStatus} ${stopData[vehicles[index].vehicle.stopId.toString()]!["stop_name"]}. Reported on ${DateTime.fromMillisecondsSinceEpoch(vehicles[index].vehicle.timestamp.toInt() * 1000).toString()}"),
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
