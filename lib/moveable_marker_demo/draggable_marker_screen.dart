import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import 'navigation_screen.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';



class DraggableMarkerScreen extends StatefulWidget {
  const DraggableMarkerScreen({Key? key}) : super(key: key);

  @override
  State<DraggableMarkerScreen> createState() => _DraggableMarkerScreenState();
}
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _DraggableMarkerScreenState extends State<DraggableMarkerScreen> {
  LatLng? destLocation = LatLng(22.7187247, 75.8575603);
  // Location location = Location();
  // loc.LocationData? _currentPosition;
  // final Completer<GoogleMapController?> _controller = Completer();
  String? _address;
  MapType currentMapType = MapType.normal;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCurrentLocation();
    // locatePosition();
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: destLocation!.latitude,
          longitude: destLocation!.longitude,
          googleMapApiKey: "AIzaSyBRvPgYBOxpkyEWXxxqErte182C245iy84");
      setState(() {
        _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  /*getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    final GoogleMapController? controller = await _controller.future;

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    if (_permissionGranted == loc.PermissionStatus.granted) {
      location.changeSettings(accuracy: loc.LocationAccuracy.high);

      _currentPosition = await location.getLocation();
      controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
        LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
        zoom: 16,
      )));
      setState(() {
        destLocation =
            LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      });
    }
  }*/
  Position? currentPosition;
  void locatePosition() async {
    try {
      await Permission.location.request();
      if (await Permission.location.request().isGranted) {
        currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        LatLng latlatposition = LatLng(currentPosition!.latitude, currentPosition!.longitude);
        CameraPosition cameraPosition = new CameraPosition(target: latlatposition, zoom: 14);

        googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      } else {
        currentPosition = null;
      }
    } catch (e) {
      print(e);

      currentPosition = null;
    }

  /*  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latlatposition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latlatposition, zoom: 14);

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // markers.add(Marker(markerId: const MarkerId('currentLocation'),
    //     position: LatLng(position.latitude, position.longitude,),
    //     icon:await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(120,120)),"assets/user_current_location.png")
    // ));

    setState(() {});*/
  }

  @override
  Widget build(BuildContext context) {
    Future<void> handlePressButton() async {
      Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: "AIzaSyBRvPgYBOxpkyEWXxxqErte182C245iy84",
          onError: onError,
          mode:  Mode.overlay,
          language: 'en',
          strictbounds: false,
          types: [""],
          logo: Container(height: 0,width: 0,),
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: 'Search',
            focusColor: Colors.grey.shade50,

          ),
          components: []
      );


      displayPrediction(p!,homeScaffoldKey.currentState);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Draggable Marker'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            mapType:currentMapType,
            markers: markers,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: destLocation!,
              zoom: 16,
            ),
            onCameraMove: (CameraPosition? position) {
              if (destLocation != position!.target) {
                setState(() {
                  destLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              print('camera idle');
              getAddressFromLatLng();
            },
            onTap: (latLng) {
              print(latLng);
            },
            onMapCreated: (GoogleMapController controller) {
              // _controller.complete(controller);
              googleMapController = controller;
              locatePosition();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Image.asset(
                'assets/user_current_location.png',
                height: 50,
                width: 50,
              ),
            ),
          ),
          Positioned(
            top:11,
            right: 20,
            left: 20,
            child: Card(
              margin: const EdgeInsets.only(right: 40),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(right: 35),
                child: Text(_address ?? 'Pick your destination address',
                    style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13),
                    overflow: TextOverflow.visible, softWrap: true),
              ),
            ),
          ),
           Positioned(
            top: 55,
            right: 7,
            child: InkWell(
              onTap: (){
                setState(() {
                  currentMapType = (currentMapType == MapType.normal) ? MapType.satellite : MapType.normal;
                });
              },
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.map,color: Colors.grey.shade600,),
                )
              ),
            ),
          ),
          Positioned(
              left: 20,
              bottom: 12,
              child: ElevatedButton(onPressed: handlePressButton, child: const Text("Search Places"))),
          Positioned(
              right: 20,
              bottom: 12,
              child: ElevatedButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return NavigationScreen(
                          destLocation!.latitude, destLocation!.longitude);
                    },
                  ),
                );
              }, child: const Text("Show polyline")))
        ],
      ),
    );
  }



  void onError(PlacesAutocompleteResponse response){
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Text("ftj")
      // AwesomeSnackbarContent(
      //   title: 'Message',
      //   message: response.errorMessage!,
      //   contentType: ContentType.failure,
      // ),
    ));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: "AIzaSyBRvPgYBOxpkyEWXxxqErte182C245iy84",
        apiHeaders: await const GoogleApiHeaders().getHeaders()
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    // markers.clear();
    // markers.add(Marker(
    //     markerId: const MarkerId("0"),
    //     position: LatLng(lat, lng),
    //     icon:await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(50,50)),"assets/search_marker.png"),
    //     infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13.5));

  }
}