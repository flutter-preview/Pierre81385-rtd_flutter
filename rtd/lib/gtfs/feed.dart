import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data_sets/route_data.dart';

class RTDFeed extends StatefulWidget {
  const RTDFeed({super.key});

  @override
  State<RTDFeed> createState() => _RTDFeedState();
}

class _RTDFeedState extends State<RTDFeed> {
  late List<FeedEntity> alerts;
  late List<FeedEntity> trips;
  late List<FeedEntity> vehicles;
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

  void RouteInfo(id) {}

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
    alerts = [];
    vehicles = [];
    trips = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AlertFeed();
    VehicaleFeed();
    TripFeed();

    return SafeArea(
      child: ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                leading: Text(routeData[
                            vehicles[index].vehicle.trip.routeId.toString()] ==
                        null
                    ? "no route data"
                    : routeData[vehicles[index]
                            .vehicle
                            .trip
                            .routeId
                            .toString()]!["route_short_name"]
                        .toString()),
                title: Text(vehicles[index].vehicle.toString()),
                subtitle: Text(
                    routeData[vehicles[index].vehicle.trip.routeId.toString()] ==
                            null
                        ? "no route data"
                        : routeData[vehicles[index]
                                .vehicle
                                .trip
                                .routeId
                                .toString()]!["route_long_name"]
                            .toString()),
                trailing: IconButton(
                    onPressed: () {}, icon: Icon(Icons.location_on)));
          }),
    );
  }
}
