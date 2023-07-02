import 'dart:collection';
import 'package:gtfs_realtime_bindings/gtfs_realtime_bindings.dart';
import 'package:rtd/data_sets/shape_data.dart';

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
      required this.trip,
      super.key});

  final double lat;
  final double long;
  final String line;
  final String route;
  final String vehicleId;
  final String status;
  final String trip;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LatLng _kMapCenter;
  late CameraPosition _kInitialPosition;
  final Map<String, Marker> _markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  late Set<Polygon> _polygon = HashSet<Polygon>();
  late List<LatLng> points = [];
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
    for (var i = 0; i <= tripData.length - 1; i++) {
      if (tripData[i]["route_id"] == widget.trip.toString() &&
          tripData[i]["direction_id"].toString() == "0") {
        print("lat ${shapes[tripData[i]["shape_id"]]!["shape_pt_lat"]}");
        print(
            "lon ${shapeData[tripData[i]["shape_id"]]!["shape_pt_lon"].toString()}");
        setState(() {
          points.add(LatLng(
              shapeData[tripData[i]["shape_id"]]!["shape_pt_lat"] as double,
              shapeData[tripData[i]["shape_id"]]!["shape_pt_lon"] as double));
        });
      }
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.clear();

      final marker = Marker(
          markerId: MarkerId(widget.vehicleId), //replace with variable!!!
          position: LatLng(widget.lat, widget.long),
          infoWindow: InfoWindow(
            title: "The " + widget.line + " line",
            snippet: widget.status + " " + widget.route,
          ),
          icon: markerIcon);
      _markers[widget.vehicleId] = marker;
    });
  }

  @override
  void initState() {
    super.initState();
    shapes = Map<String, Map<String, Object>>.from(shapeData);
    getPoints();
    _kMapCenter = LatLng(widget.lat, widget.long);
    _kInitialPosition =
        CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);
    _polygon.add(Polygon(
      // given polygonId
      polygonId: PolygonId('1'),
      // initialize the list of points to display polygon
      points: points,
      // given color to polygon
      fillColor: Colors.green.withOpacity(0.3),
      // given border color to polygon
      strokeColor: Colors.green,
      geodesic: true,
      // given width of border
      strokeWidth: 4,
    ));
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
            polygons: _polygon,
          ),
        ),
      ],
    );
  }
}
