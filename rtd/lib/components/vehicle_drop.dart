import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class VehicleSelection extends StatefulWidget {
  const VehicleSelection({required this.onChange, super.key});
  final ValueChanged<String> onChange;

  @override
  State<VehicleSelection> createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends State<VehicleSelection> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text('Select a Line'), value: "select"),
      DropdownMenuItem(
          child: Text("A - Union Station to Denver Airport Station"),
          value: "A"),
      DropdownMenuItem(
          child: Text("B - Union Station to Westminster"), value: "B"),
      DropdownMenuItem(
          child: Text("D - 18th & California to Littleton - Mineral Station"),
          value: "D"),
      DropdownMenuItem(
          child: Text("E - Union Station to RidgeGate Parkway Station"),
          value: "E"),
      DropdownMenuItem(
          child: Text("G - Union Station to Wheat Ridge Ward Station"),
          value: "G"),
      DropdownMenuItem(
          child: Text("H - 18th & California to Florida Station"), value: "H"),
      DropdownMenuItem(
          child: Text("L - 30th & Downing to 16th & Stout"), value: "L"),
      DropdownMenuItem(
          child: Text("N - Union Station to Eastlake Station"), value: "N"),
      DropdownMenuItem(
          child: Text("R - Peoria Station to RidgeGate Parkway Station"),
          value: "R"),
      DropdownMenuItem(
          child: Text("W - Union Station to JeffCo - Golden Station"),
          value: "W"),
    ];
    return menuItems;
  }

  late String selectedValue;

  @override
  void initState() {
    selectedValue = "select";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: selectedValue,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedValue = value!;
        });
        widget.onChange(value!);
        print(value);
        print(selectedValue);
      },
    );
  }
}
