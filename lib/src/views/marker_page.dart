import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerPage extends StatefulWidget {
  @override
  _MarkerPageState createState() => _MarkerPageState();
}

class _MarkerPageState extends State<MarkerPage> {

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;
  bool _initialized = false;
  bool _error = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  GoogleMapController _controller;
  static final CameraPosition _initCamPos = CameraPosition(
    target: LatLng(38.12585158237043, -92.71793095533938),
    zoom: 15.4746,
  );

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  static final CameraPosition _resort = CameraPosition(
      bearing: 340,
      target: LatLng(38.12585158237043, -92.71793095533938),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Algo fallo'),
        ),
      );
    }
    if (!_initialized) {
      return CircularProgressIndicator();
    }

    return new Scaffold(
      body: Stack(children: [
        GoogleMap(
          markers: Set<Marker>.of(_markers.values),
          mapType: MapType.hybrid,
          initialCameraPosition: _initCamPos,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            _readData();
          },
          onTap: _handleTap,
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onPressed: _goToResort,
              child: Icon(Icons.directions_boat_rounded)),
        ),
        Positioned(
          bottom: 10,
          right: 100,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            onPressed: _removeMarker,
            child: Icon(Icons.delete),
          ),
        )
      ], overflow: Overflow.clip),
    );
  }

  void _removeMarker() {
    if (selectedMarker != null) {
      firestore.collection('places').doc(selectedMarker.value).delete();
      setState(() {
        _markers.remove(selectedMarker);
      });
    }
  }

  void _readData() async {
    final QuerySnapshot result = await firestore.collection('places').get();
    final List<DocumentSnapshot> documents = result.docs;
    int count = 0;
    documents.forEach((data) {
      Map<String, dynamic> datos = data.data();
      GeoPoint tmp = datos['position'];
      if (count < int.parse(data.id)) count = int.parse(data.id);
      final MarkerId markerId = MarkerId(data.id);
      LatLng point = LatLng(tmp.latitude, tmp.longitude);
      final Marker marker = Marker(
          markerId: markerId,
          position: point,
          infoWindow: InfoWindow(title: 'Id: ' + data.id),
          onTap: () {
            _onTapped(markerId);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow));
      _markers[markerId] = marker;
    });
    _markerIdCounter = count + 1;
    setState(() {});
  }

  Future<void> _goToResort() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(_resort));
  }

  void _handleTap(LatLng point) {
    final MarkerId markerId = MarkerId(_markerIdCounter.toString());
    GeoPoint geoPoint = GeoPoint(point.latitude, point.longitude);
    final Marker marker = Marker(
        markerId: markerId,
        position: point,
        infoWindow: InfoWindow(title: 'Id: ' + _markerIdCounter.toString()),
        onTap: () {
          _onTapped(markerId);
        },
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow));
    firestore
        .collection('places')
        .doc(_markerIdCounter.toString())
        .set({"position": geoPoint});
    setState(() {
      _markers[markerId] = marker;
    });
    _markerIdCounter++;
  }

  void _onTapped(MarkerId markerId) {
    final Marker tappedMarker = _markers[markerId];
    if (tappedMarker != null) {
      if (_markers.containsKey(markerId)) {
        selectedMarker = markerId;
      }
    }
  }
}
