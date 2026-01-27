import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:map/middlewares/propowner.dart';
import 'package:map/middlewares/user.dart';
import 'package:map/repositories/user_repository.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title, required this.color});
  final String title;
  final Color color;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latRangeController = TextEditingController();
  final TextEditingController _lngRangeController = TextEditingController();

  late Future<List<User>> futureUser;

  final UserRepository _repo = UserRepository();
  final _propBox = Hive.box<PropertyOwener>('propertyOwnerBox');

  double? _parseValuation(String v) {
    return double.tryParse(v.replaceAll(',', ''));
  }

  final Set<Marker> _markers = {};
  final CustomInfoWindowController _infoController =
      CustomInfoWindowController();

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(5.679483, -0.182115),
    zoom: 12,
  );

  String _searchText = "";
  String? selectedCity;
  bool showFilters = false;
  RangeValues? _latRange;
  RangeValues? _lngRange;

  // LatLng? _centerPoint;
  // double _radiusKm = 5;

  final List<String> cityOptions = [
    'All',
    'Accra',
    'Kumasi',
    'Takoradi',
    'Tamale',
  ];

  @override
  void initState() {
    super.initState();
    futureUser = _repo.fetchUsers();
    _repo.importCSVToHiveOptimized();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latRangeController.dispose();
    _lngRangeController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  void _performSearch() => setState(() {
    _searchText = _searchController.text.trim();
  });

  List<MapEntry<dynamic, PropertyOwener>> _applyFilters(
    Box<PropertyOwener> box,
  ) {
    return box.toMap().entries.where((entry) {
      final prop = entry.value;
      final query = _searchText.toLowerCase();

      // 🔍 TEXT SEARCH (name, valuation, amount)
      if (query.isNotEmpty) {
        final matchesText =
            prop.name.toLowerCase().contains(query) ||
            prop.valuation.toLowerCase().contains(query) ||
            prop.amount.toLowerCase().contains(query);

        if (!matchesText) return false;
      }

      final lat = double.tryParse(prop.latitude);
      final lng = double.tryParse(prop.longitude);
      if (lat == null || lng == null) return false;

      // 🌍 LAT FILTER
      if (_latRange != null &&
          (lat < _latRange!.start || lat > _latRange!.end)) {
        return false;
      }

      // 🌍 LNG FILTER
      if (_lngRange != null &&
          (lng < _lngRange!.start || lng > _lngRange!.end)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _resetFilters() {
    _searchController.clear();
    selectedCity = null;
    // _radiusKm = 5;
    // _centerPoint = null;
    _infoController.hideInfoWindow?.call();
    setState(() {
      _searchText = "";
    });
  }

  List<double>? parseRange(String input) {
    try {
      final parts = input.split('-');
      if (parts.length != 2) return null;
      final min = double.parse(parts[0].trim());
      final max = double.parse(parts[1].trim());
      return [min, max];
    } catch (_) {
      return null;
    }
  }

  Future<void> _showEditDialog(PropertyOwener prop, dynamic hiveKey) async {
    final nameCtrl = TextEditingController(text: prop.name);
    final valCtrl = TextEditingController(text: prop.valuation);
    final amtCtrl = TextEditingController(text: prop.amount);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Property'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(labelText: 'Valuation'),
            ),
            TextField(
              controller: amtCtrl,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final updated = PropertyOwener(
                name: nameCtrl.text,
                valuation: valCtrl.text,
                amount: amtCtrl.text,
                latitude: prop.latitude,
                longitude: prop.longitude,
              );

              await _propBox.put(hiveKey, updated);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _fitMapToMarkers(List<Marker> markers) async {
    if (markers.isEmpty) return;
    final controller = _infoController.googleMapController;
    if (controller == null) return;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (final marker in markers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Widget _buildPropertyInfoWindow(PropertyOwener prop, dynamic hiveKey) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prop.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text('Valuation: ${prop.valuation}'),
          Text('Amount: ${prop.amount}'),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                onPressed: () {
                  _infoController.hideInfoWindow?.call();
                  _showEditDialog(prop, hiveKey);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  await _propBox.delete(hiveKey);
                  _infoController.hideInfoWindow?.call();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _buildPropertyMarkers(List<MapEntry<dynamic, PropertyOwener>> entries) {
    _markers.clear();

    for (final entry in entries) {
      final key = entry.key;
      final prop = entry.value;

      final lat = double.tryParse(prop.latitude);
      final lng = double.tryParse(prop.longitude);
      if (lat == null || lng == null) continue;

      final position = LatLng(lat, lng);

      _markers.add(
        Marker(
          markerId: MarkerId(key.toString()),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () {
            _infoController.addInfoWindow!(
              _buildPropertyInfoWindow(prop, key),
              position,
            );
          },
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToMarkers(_markers.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'images/Coat_of_arms_of_Ghana.svg',
          height: 36,
          fit: BoxFit.contain,
        ),

        backgroundColor: widget.color,
        actions: [
          IconButton(
            icon: Icon(showFilters ? Icons.expand_less : Icons.filter_list),
            onPressed: () => setState(() => showFilters = !showFilters),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            setState(() => futureUser = _repo.fetchUsers(forceRefresh: true)),
        child: Column(
          children: [
            if (showFilters)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _performSearch(),
                            decoration: InputDecoration(
                              hintText: "Search by name...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch();
                                },
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _performSearch,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownMenu<String>(
                            dropdownMenuEntries: cityOptions
                                .map(
                                  (e) => DropdownMenuEntry(value: e, label: e),
                                )
                                .toList(),
                            initialSelection: cityOptions.first,
                            hintText: "City",
                            onSelected: (value) => setState(
                              () =>
                                  selectedCity = value == 'All' ? null : value,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     await _repo.importCSVToHiveOptimized();
                    //   },
                    //   child: const Text('Import Excel File'),
                    // ),
                    // const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => setState(() {}),
                            child: const Text("Apply Filters"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _resetFilters,
                            child: const Text("Reset Filters"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _propBox.listenable(),
                builder: (context, Box<PropertyOwener> box, _) {
                  final filteredEntries = _applyFilters(box);

                  _buildPropertyMarkers(filteredEntries);

                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialCamera,
                        markers: _markers,
                        myLocationEnabled: true,
                        onMapCreated: (controller) =>
                            _infoController.googleMapController = controller,
                        onTap: (_) => _infoController.hideInfoWindow?.call(),
                        onCameraMove: (_) =>
                            _infoController.onCameraMove?.call(),
                        onLongPress: (point) => setState(() {
                          // _centerPoint = point;
                        }),
                      ),
                      CustomInfoWindow(
                        controller: _infoController,
                        height: 160,
                        width: 260,
                        offset: 40,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
