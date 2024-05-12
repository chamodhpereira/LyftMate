import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lyft_mate/screens/offer_ride/ui/select_waypoint_screen.dart';

class EditRoutePage extends StatefulWidget {
  final LatLng initialPickupLocation;
  final LatLng initialDropoffLocation;
  final bool initialAvoidHighways;
  final bool initialAvoidTolls;
  final bool initialAvoidFerries;

  const EditRoutePage({
    Key? key,
    required this.initialPickupLocation,
    required this.initialDropoffLocation,
    this.initialAvoidHighways = false,
    this.initialAvoidTolls = false,
    this.initialAvoidFerries = false,
  }) : super(key: key);

  @override
  _EditRoutePageState createState() => _EditRoutePageState();
}

class _EditRoutePageState extends State<EditRoutePage> {
  final TextEditingController waypoint1Controller = TextEditingController();
  final TextEditingController waypoint2Controller = TextEditingController();
  LatLng? waypoint1;
  LatLng? waypoint2;

  // Initialize checkbox states using passed-in values
  late bool avoidHighways;
  late bool avoidTolls;
  late bool avoidFerries;

  @override
  void initState() {
    super.initState();
    // Set checkbox states based on values passed in via the constructor
    avoidHighways = widget.initialAvoidHighways;
    avoidTolls = widget.initialAvoidTolls;
    avoidFerries = widget.initialAvoidFerries;
  }

  // Update the selected waypoint 1
  void _updateWaypoint1(Map<String, dynamic> waypointData) {
    setState(() {
      waypoint1 = waypointData['latLng'];
      waypoint1Controller.text = waypointData['description'];
    });
  }

  // Update the selected waypoint 2
  void _updateWaypoint2(Map<String, dynamic> waypointData) {
    setState(() {
      waypoint2 = waypointData['latLng'];
      waypoint2Controller.text = waypointData['description'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Route'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                const Text("Route Options", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                CheckboxListTile(
                  title: const Text('Avoid Highways'),
                  value: avoidHighways,
                  onChanged: (bool? value) {
                    setState(() {
                      avoidHighways = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Avoid Tolls'),
                  value: avoidTolls,
                  onChanged: (bool? value) {
                    setState(() {
                      avoidTolls = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Avoid Ferries'),
                  value: avoidFerries,
                  onChanged: (bool? value) {
                    setState(() {
                      avoidFerries = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 25),
                const Text("Destinations", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                const SizedBox(height: 20),
                _buildWaypointInputField("Waypoint 1", waypoint1Controller, _updateWaypoint1),
                const SizedBox(height: 10),
                _buildWaypointInputField("Waypoint 2", waypoint2Controller, _updateWaypoint2),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50.0,
                color: Colors.transparent,
                child:
                ElevatedButton(
                  onPressed: () {
                  List<LatLng> waypoints = [];
                  if (waypoint1 != null) waypoints.add(waypoint1!);
                  if (waypoint2 != null) waypoints.add(waypoint2!);

                  Navigator.pop(context, {
                    'waypoints': waypoints,
                    'avoidHighways': avoidHighways,
                    'avoidTolls': avoidTolls,
                    'avoidFerries': avoidFerries,
                  });
                },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: const Text(
                      "Update Route",
                      // style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)
                  ),
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointInputField(String label, TextEditingController controller, Function(Map<String, dynamic>) updateWaypoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'Search for a location',
          ),
          onTap: () async {
            final Map<String, dynamic>? waypointData = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectWaypointsScreen(waypointLabel: label),
              ),
            );

            if (waypointData != null) {
              updateWaypoint(waypointData);
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
