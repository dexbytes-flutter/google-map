import 'package:flutter/material.dart';
import 'package:google_map_test/pages/custom_marker_screen.dart';
import 'package:google_map_test/pages/map_polyline.dart';
import 'package:google_map_test/pages/search_place_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Google Map Service List'),),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: const Text('Google map current location'),
              onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomMarkerScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Google map polyline'),
              onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPolyline()));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Google map search location'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPlacesScreen()));
              },
            ),
          )
        ],
      )
    );
  }
}
