import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clippy_flutter/triangle.dart';

class MapHome extends StatefulWidget {
  const MapHome({super.key});

  @override
  State<MapHome> createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  bool _isLocationEnabled = false;
  final LatLng _initialPosition = const LatLng(5.679483, -0.182115);
  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      setState(() {
        _isLocationEnabled = true;
      });
    }
  }

  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final Set<Marker> _markers = {};

  void _addMarker(
    LatLng position,
    String id,
    String title,
    String description,
  ) {
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: position,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 8.0),

                              Text(
                                description,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            child: const Text("Tap Me!"),
                            onPressed: () {
                              // Add your button's functionality here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Button tapped!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Triangle.isosceles(
                      edge: Edge.BOTTOM,
                      child: Container(
                        color: Colors.blue,
                        width: 30.0,
                        height: 20.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            position,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    _requestLocationPermission();
    _addMarker(_initialPosition, 'maker_1', 'My Location', 'This is my ');
    super.initState();

    // Listen for changes in the text field in real-time
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    _customInfoWindowController.dispose();
    super.dispose();
  }

  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(5.679483, -0.182115),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Home')),
      body: _isLocationEnabled
          ? Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _customInfoWindowController.googleMapController =
                        controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onTap: (position) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  onLongPress: (argument) => {
                    _addMarker(
                      argument,
                      'marker_${_markers.length + 1}',
                      'Custom Marker ${_markers.length + 1}',
                      'This is a custom marker added by long press.',
                    ),
                    setState(() {}),
                  },
                  onCameraMove: (position) =>
                      _customInfoWindowController.onCameraMove!(),
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 200,
                  width: 200,
                  offset: 50,
                ),
              ],
            )
          : const Center(child: Text('Location permission is not granted.')),
    );
  }
}
