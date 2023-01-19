import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CustomMarkerScreen extends StatefulWidget {
  const CustomMarkerScreen({Key? key}) : super(key: key);

  @override
  State<CustomMarkerScreen> createState() => _CustomMarkerScreenState();
}

class _CustomMarkerScreenState extends State<CustomMarkerScreen> {
  LatLng initialLocation = const LatLng(22.744932552589095, 75.89233791554845);
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  late GoogleMapController googleMapController;
  late double currentLat; //= 22.737795071763955;
  late double currentLong; //= 75.89323762182066;
  String googleApikey = "GOOGLE_MAP_API_KAY";
  Set<Marker> markers = {};
  TextEditingController _selectedField = TextEditingController(text: '');
  final TextEditingController _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '';
  List<dynamic> _placeList = [];
  // final GlobalKey<NavigatorState> ctx = new GlobalKey<NavigatorState>();
  final ctx = GlobalKey<ScaffoldState>();

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    String kPLACESAPIKEY = "AIzaSyBRvPgYBOxpkyEWXxxqErte182C245iy84";
    String type = '(regions)';

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$kPLACESAPIKEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('mydata');
      print(data);
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  void getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) async {
      currentLong = value.longitude;
      currentLat = value.latitude;
      markers.add(Marker(
        draggable: true,
          markerId: const MarkerId('genie1'),
          position: LatLng(currentLat, currentLong),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(), "assets/app_icon/genie_icon.png")));
    });
    setState(() {});
  }

  Future<void> getSelectedLocation(double lat,double long) async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) async {
      markers.add(Marker(
        draggable: true,
          markerId: const MarkerId('genie1'),
          position: LatLng(lat, long),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(), "assets/app_icon/genie_icon.png")));
    });
      setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getUserCurrentLocation();
    });
    _controller.addListener(() {
      _onChanged();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Custom Marker'),
      // ),
      body: Stack(
        children: [
          GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
                getUserCurrentLocation();
              },
              initialCameraPosition: CameraPosition(
                target: initialLocation,
                zoom: 10,
              ),
              zoomControlsEnabled: true,
              myLocationEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              markers: markers
          ),
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: <Widget>[
      //       Align(
      //         alignment: Alignment.topCenter,
      //         child: TextFormField(
      //           controller: _controller,
      //           decoration: InputDecoration(
      //             fillColor: Colors.white,
      //             filled: true,
      //             border: InputBorder.none,
      //             hintText: "Search place",
      //             focusColor: Colors.white,
      //             floatingLabelBehavior: FloatingLabelBehavior.never,
      //             prefixIcon: const Icon(Icons.location_on),
      //             suffixIcon: IconButton(
      //               icon: const Icon(Icons.cancel), onPressed: () {
      //               _controller.clear() ;
      //             },
      //             ),
      //           ),
      //           onTap: (){
      //             _selectedField = _controller;
      //           },
      //         ),
      //       ),
      //       ListView.builder(
      //         physics: const NeverScrollableScrollPhysics(),
      //         shrinkWrap: true,
      //         itemCount: _placeList.length,
      //         itemBuilder: (context, index) {
      //           return GestureDetector(
      //             onTap: () async {
      //               if(_selectedField != null){
      //                 _selectedField.value = TextEditingValue(text: _placeList[index]["description"]);
      //                 String locationAddress = await _placeList[index]["description"];
      //                 List<Location> location = await locationFromAddress(locationAddress);
      //                 currentLat = location.last.latitude;
      //                 currentLong = location.last.longitude;
      //                   getUserCurrentLocation();
      //               }
      //             },
      //             child: Container(
      //               decoration: const BoxDecoration(color: Colors.white),
      //               child: ListTile(
      //                 tileColor: Colors.white,
      //                 title: Text(_placeList[index]["description"],maxLines: 2,),
      //               ),
      //             ),
      //           );
      //         },
      //       )
      //     ],
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
