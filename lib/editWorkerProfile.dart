import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_osm_interface/flutter_osm_interface.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class EditWorkerProfile extends StatefulWidget {
  const EditWorkerProfile({super.key});

  @override
  State<EditWorkerProfile> createState() => _EditWorkerProfileState();
}

class _EditWorkerProfileState extends State<EditWorkerProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Pick Location'),
      // ),
      // body: OSMMap(
      //   center: LatLng(_latitude, _longitude), // Initial center (optional)
      //   zoomLevel: 15.0, // Zoom level
      //   onMapTap: _onMapTap,
      // ),
      // floatingActionButton: _latitude != 0.0 ? FloatingActionButton(
      //   onPressed: () {
      //     // Save location to your database here
      //     // ... your code to save (_latitude, _longitude) to DB
      //     Navigator.pop(context); // Close the screen after saving
      //   },
      //   child: Icon(Icons.check),
      // ) : null,
    );
  }
}
