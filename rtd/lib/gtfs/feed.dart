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
  late String Name;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (BuildContext context, int index) {
            return routeData[vehicles[index].vehicle.trip.routeId.toString()] ==
                    null
                ? const SizedBox()
                : widget.vehicle == "select"
                    ? SizedBox()
                    : routeData[vehicles[index]
                                    .vehicle
                                    .trip
                                    .routeId
                                    .toString()]!["route_short_name"]
                                .toString() ==
                            widget.vehicle
                        ? ListTile(
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
                                        .toString()]!["route_short_name"]
                                    .toString()),
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
                            trailing: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => MapView(
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
                                                : routeData[vehicles[index].vehicle.trip.routeId.toString()]!["route_short_name"]
                                                    .toString(),
                                            vehicleId: vehicles[index]
                                                .vehicle
                                                .vehicle
                                                .id,
                                            status: vehicles[index]
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
                                                    .toString())),
                                  );
                                },
                                icon: const Icon(Icons.location_on)),
                            subtitle: Text(vehicles[index]
                                    .vehicle
                                    .currentStatus
                                    .toString() +
                                " " +
                                stopData[vehicles[index]
                                        .vehicle
                                        .stopId
                                        .toString()]!["stop_name"]
                                    .toString()),
                          )
                        : const SizedBox();
          }),
    );
  }
}
