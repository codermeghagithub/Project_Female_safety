import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart'; // For sharing links

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  Position? _position;
  late bool servicePermission = false;
  late LocationPermission permission;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  String _currentAddress = "";
  String _storedAddress = "Fetching...";

  // Google Maps controller
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Stream subscription for real-time location updates
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchStoredLocation();
    _startRealTimeLocationTracking();
  }

  // Start real-time location tracking
  void _startRealTimeLocationTracking() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Location Service Disabled");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location Permission Denied");
        return;
      }
    }

    // Listen to location updates
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _position = position;
      });
      _getAddressFromCoordinates();
      _storeLocationInFirebase();
    });
  }

  // Stop real-time location tracking
  void _stopRealTimeLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // Store location in Firebase Realtime Database
  _storeLocationInFirebase() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && _position != null) {
        String userId = user.uid;
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(userId)
            .child("locationDetails");

        await ref.set({
          "latitude": _position!.latitude,
          "longitude": _position!.longitude,
          "address": _currentAddress,
          "timestamp": DateTime.now().toString(),
        });

        print(
            "Location stored successfully in Firebase under locationDetails!");
      } else {
        print("User not logged in or position is null.");
      }
    } catch (error) {
      print("Error storing location: $error");
    }
  }

  // Get current position
  Future<Position> _getCurrentPosition() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service Disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  // Get address from coordinates and update marker
  _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _position!.latitude, _position!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.country}, ${place.subThoroughfare}, ${place.street}, "
            "${place.administrativeArea}, ${place.subAdministrativeArea}, ${place.postalCode}";

        // Update marker on the map
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId("current_location"),
            position: LatLng(_position!.latitude, _position!.longitude),
            infoWindow:
                InfoWindow(title: "Current Location", snippet: _currentAddress),
          ),
        );

        // Move camera to the current location
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(_position!.latitude, _position!.longitude),
              15,
            ),
          );
        }
      });

      // Save to Firebase
      if (userId != null) {
        _dbRef.child('users').child(userId!).child('location').set({
          "latitude": _position!.latitude,
          "longitude": _position!.longitude,
          "locality": place.locality,
          "country": place.country,
          "street": place.street,
          "state": place.administrativeArea,
          "district": place.subAdministrativeArea,
          "postalCode": place.postalCode,
        }).then((_) {
          print("✅ Location saved to Firebase!");
        }).catchError((error) {
          print("❌ Failed to save location: $error");
        });
      } else {
        print("❌ User not logged in!");
      }
    } catch (e) {
      print(e);
    }
  }

  // Fetch stored location
  void _fetchStoredLocation() {
    if (userId != null) {
      _dbRef
          .child('users')
          .child(userId!)
          .child('location')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            _storedAddress =
                "Latitude: ${data['latitude']}, Longitude: ${data['longitude']}\n"
                "Locality: ${data['locality']}, Street: ${data['street']}, "
                "State: ${data['state']}, Postal Code: ${data['postalCode']}";

            // Add stored location as a marker
            _markers.add(
              Marker(
                markerId: MarkerId("stored_location"),
                position: LatLng(
                  data['latitude'] as double,
                  data['longitude'] as double,
                ),
                infoWindow: InfoWindow(
                    title: "Stored Location", snippet: _storedAddress),
              ),
            );
          });
        }
      });
    }
  }

  // Generate and share live location link
  void _shareLiveLocation() {
    if (userId != null && _position != null) {
      // Create a shareable link (you can use a deep link or a web URL)
      String shareableLink =
          "https://maps.google.com/?q=${_position!.latitude},${_position!.longitude}";
      Share.share(
        "Track my live location: $shareableLink",
        subject: "My Live Location",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to share location. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Tracker"),
      ),
      body: Column(
        children: [
          // Google Map widget
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _position != null
                    ? LatLng(_position!.latitude, _position!.longitude)
                    : LatLng(0, 0),
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          // Other UI elements
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Location Coordinates",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text("Coordinates"),
                  SizedBox(height: 6),
                  Text(
                    "Latitude: ${_position?.latitude ?? 'N/A'}, Longitude: ${_position?.longitude ?? 'N/A'}",
                  ),
                  SizedBox(height: 6),
                  Text(_currentAddress),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      _position = await _getCurrentPosition();
                      await _getAddressFromCoordinates();
                      await _storeLocationInFirebase();
                      print("Position: $_position");
                      print("Address: $_currentAddress");
                    },
                    child: Text("Get Location"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _shareLiveLocation,
                    child: Text("Share Live Location"),
                  ),

                  // SizedBox(height: 10),
                  // Text("Stored Location:"),
                  // Text(_storedAddress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopRealTimeLocationTracking();
    _mapController?.dispose();
    super.dispose();
  }
}
