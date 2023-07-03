import 'dart:collection';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:rtd/data_sets/shape_data.dart';
import 'package:rtd/data_sets/stop_data.dart';

import '../data_sets/trip_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rtd/app.dart';

class MapView extends StatefulWidget {
  const MapView(
      {required this.lat,
      required this.long,
      required this.vehicleId,
      required this.line,
      required this.route,
      required this.status,
      required this.stops,
      super.key});

  final double lat;
  final double long;
  final String line;
  final String route;
  final String vehicleId;
  final String status;
  final List<TripUpdate_StopTimeUpdate> stops;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LatLng _kMapCenter;
  late CameraPosition _kInitialPosition;
  final Map<String, Marker> _markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  // late Set<Polyline> _Polyline = HashSet<Polyline>();
  late Set<Polyline> points = {};
  late Map<String, Map<String, Object>> shapes;

  void addCustomIcon(asset) {
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), asset).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  void getPoints() {
    for (var i = 0; i < widget.stops.length - 1; i++) {
      setState(() {
        final stationMarker = Marker(
            markerId: MarkerId(widget.stops[i].stopId),
            position: LatLng(
                stopData[widget.stops[i].stopId]!["stop_lat"] as double,
                stopData[widget.stops[i].stopId]!["stop_lon"] as double),
            infoWindow: InfoWindow(
                title:
                    stopData[widget.stops[i].stopId]!["stop_name"].toString()));
        _markers[widget.stops[i].stopId] = stationMarker;
        points.add(Polyline(
          polylineId: PolylineId(
              stopData[widget.stops[i].stopId]!["stop_name"].toString()),
          visible: true,
          width: 5, //width of polyline
          points: [
            LatLng(
                stopData[widget.stops[i].stopId]!["stop_lat"] as double,
                stopData[widget.stops[i].stopId]!["stop_lon"]
                    as double), //start point
            LatLng(
                stopData[widget.stops[i + 1].stopId]!["stop_lat"] as double,
                stopData[widget.stops[i + 1].stopId]!["stop_lon"]
                    as double), //end point
          ],
          color: Colors.deepPurpleAccent, //color of polyline
        ));
        // points.add({
        //   LatLng(stopData[widget.stops[i].stopId]!["stop_lat"] as double,
        //       stopData[widget.stops[i].stopId]!["stop_lon"] as double),
        //   LatLng(stopData[widget.stops[i + 1].stopId]!["stop_lat"] as double,
        //       stopData[widget.stops[i + 1].stopId]!["stop_lon"] as double)
        // });
      });
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.clear();
      final trainMarker = Marker(
          markerId: MarkerId(widget.vehicleId),
          position: LatLng(widget.lat, widget.long),
          infoWindow: InfoWindow(
            title: "The " + widget.line + " line",
            snippet: widget.status + " " + widget.route,
          ),
          icon: markerIcon);

      _markers[widget.vehicleId] = trainMarker;
      getPoints();
    });
  }

  @override
  void initState() {
    super.initState();
    shapes = Map<String, Map<String, Object>>.from(shapeData);
    getPoints();
    _kMapCenter = LatLng(widget.lat, widget.long);
    _kInitialPosition =
        CameraPosition(target: _kMapCenter, zoom: 10.0, tilt: 0, bearing: 0);
    // _Polyline.add(Polyline(
    //     polylineId: PolylineId('1'),
    //     points: points,
    //     color: Colors.green,
    //     geodesic: true,
    //     width: 4,
    //     startCap: Cap.buttCap,
    //     endCap: Cap.buttCap));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => RTDApp()),
                  );
                },
                child: Icon(Icons.arrow_back_ios_new))
          ],
        ),
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kInitialPosition,
            markers: _markers.values.toSet(),
            polylines: points,
          ),
        ),
      ],
    );
  }
}
