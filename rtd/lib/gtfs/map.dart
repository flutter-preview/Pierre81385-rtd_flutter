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
      super.key});

  final double lat;
  final double long;
  final String line;
  final String route;
  final String vehicleId;
  final String status;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LatLng _kMapCenter;
  late CameraPosition _kInitialPosition;
  final Map<String, Marker> _markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon(asset) {
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(), asset).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
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
    addCustomIcon("");
    _kMapCenter = LatLng(widget.lat, widget.long);
    _kInitialPosition =
        CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);
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
          ),
        ),
      ],
    );
  }
}
