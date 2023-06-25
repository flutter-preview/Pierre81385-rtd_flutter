import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'components/vehicle_drop.dart';
import 'gtfs/feed.dart';

class RTDApp extends StatefulWidget {
  const RTDApp({super.key});

  @override
  State<RTDApp> createState() => _RTDAppState();
}

class _RTDAppState extends State<RTDApp> {
  late String _vehicleSelected = "select";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                VehicleSelection(onChange: (value) {
                  setState(() {
                    _vehicleSelected = value;
                  });
                })
              ],
            ),
            Expanded(
                child: RTDFeed(
              vehicle: _vehicleSelected,
            )),
          ],
        ),
      ),
    );
  }
}
