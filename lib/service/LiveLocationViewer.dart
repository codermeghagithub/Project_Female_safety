import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_database/firebase_database.dart';

class LiveLocationViewer extends StatefulWidget {
  final String sharedUserId;

  const LiveLocationViewer({super.key, required this.sharedUserId});

  @override
  State<LiveLocationViewer> createState() => _LiveLocationViewerState();
}

class _LiveLocationViewerState extends State<LiveLocationViewer> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _address = "Fetching...";
  LatLng? _sharedPosition;

  @override
  void initState() {
    super.initState();
    _listenToSharedLocation();
  }

  void _listenToSharedLocation() {
    FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(widget.sharedUserId)
        .child('location')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _sharedPosition =
              LatLng(data['latitude'] as double, data['longitude'] as double);
          _address =
              "Locality: ${data['locality']}, Street: ${data['street']}, State: ${data['state']}, Postal Code: ${data['postalCode']}";
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId("shared_location"),
              position: _sharedPosition!,
              infoWindow:
                  InfoWindow(title: "Shared Location", snippet: _address),
            ),
          );

          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(_sharedPosition!, 15),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Live Location")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _sharedPosition ?? LatLng(0, 0),
                zoom: 15,
              ),
              markers: _markers,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(_address),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
