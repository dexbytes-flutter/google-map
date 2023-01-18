import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';


class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

const kGoogleApiKey = 'AIzaSyBRvPgYBOxpkyEWXxxqErte182C245iy84';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(22.7187247, 75.8575603), zoom: 14);

  Set<Marker> markers = {};
  final Mode mode = Mode.overlay;
  late Position currentPosition;


  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latlatposition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latlatposition, zoom: 14);

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    markers.add(Marker(markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude,),
        icon:await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(120,120)),"assets/user_current_location.png")
    ));

    setState(() {});
  }

  static final CameraPosition userLocation = CameraPosition(
    target: LatLng(26.0667, 50.5577),
    zoom: 15,
  );


  @override
  void initState(){
    locatePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> handlePressButton() async {
      Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: mode,
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
        title: const Text("User current location"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: userLocation,
            markers:markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              locatePosition();
              currentLocationMarker();
            },
          ),
          ElevatedButton(onPressed: handlePressButton, child: const Text("Search Places"))

        ],
      ),
    /*  floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _determinePosition();

          googleMapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 14)));


          // markers.clear();

          markers.add(Marker(markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude,),
              icon:await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(120,120)),"assets/user_current_location.png")

          ));
          setState(() {});
        },
        label: const Text("Current Location"),
        icon: const Icon(Icons.location_history),
      ),*/
    );
  }


  void currentLocationMarker() async {
    markers.add(Marker(markerId: const MarkerId('NewcurrentLocation'),
        position: LatLng(currentPosition.latitude, currentPosition.longitude,),
        icon:await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(120,120)),"assets/user_current_location.png")

    ));
  }



/*  // For Current Location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }*/

  // For Search Location
  void onError(PlacesAutocompleteResponse response){

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

    // homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders()
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    // markers.clear();
    markers.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        icon:await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(50,50)),"assets/search_marker.png"),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));

  }

}
