import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_tutorial/place_picker.dart';
import 'package:google_maps_flutter_tutorial/screens/current_location_screen.dart';
import 'package:google_maps_flutter_tutorial/screens/simple_map_screen.dart';

import 'moveable_marker_demo/draggable_marker_screen.dart';
import 'screens/polyline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng initialPositionOfDetailMap = LatLng(22.7187247, 75.8575603);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Google Maps"),
        centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return const SimpleMapScreen();
              }));
            }, child: const Text("Simple Map")),

            ElevatedButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
                return const CurrentLocationScreen();
              }));
            }, child: const Text("User current location")),

            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PlacePicker(
                      initialPosition:initialPositionOfDetailMap,
                      useCurrentLocation: true,
                      backgroundColor:Colors.grey,
                      selectInitialPosition: true,
                      onPlacePicked: (result) async {
                        // setAddressFields(result);
                        Navigator.of(context).pop();
                        if (mounted) {
                          setState(() {
                            // isAddressPicked = true;
                            // initialPositionOfDetailMap = LatLng(result.geometry!.location.lat, result.geometry!.location.lng);
                          });
                        }
                      },
                      controllerCallBack: (value){
                        print("Hello ");
                      },
                    );
                  },
                ),
              );
            }, child: const Text("Auto Complete ")),

            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DraggableMarkerScreen();
                  },
                ),
              );
            }, child: const Text("Draggable Marker")),
          ],
        ),
      ),
    );
  }
}
