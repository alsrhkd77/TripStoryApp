import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripstory/modules/ImageModule.dart';
import 'package:tripstory/modules/UtilityModule.dart';

class Maps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  Size deviceSize;
  List<Widget> imgs = [];
  List<String> imgs_path = [];
  List posList = [];

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void showMessage(String msg) {
    final snackbar = SnackBar(content: Text(msg));

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);
  }

  void addMarker(LatLng pos) {
    // Create a new marker
    Marker resultMarker = Marker(
        markerId: MarkerId(pos.toString()),
        infoWindow: InfoWindow(title: "title", snippet: "asd"),
        //position: LatLng(37.43296265331129, -122.08832357078792),
        position: pos,
        onTap: () {
          showMessage("msg");
          /*
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: const Text('Choose Options'),
              message: const Text('Your options are '),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: const Text('One'),
                  onPressed: () {
                    Navigator.pop(context, 'One');
                  },
                ),
                CupertinoActionSheetAction(
                  child: const Text('Two'),
                  onPressed: () {
                    Navigator.pop(context, 'Two');
                  },
                )
              ],
              cancelButton: CupertinoActionSheetAction(
                child: const Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                },
              ),
            ),
          );
           */
        });
// Add it to Set
    setState(() {
      markers.add(resultMarker);
    });
    _goToTarget(pos);
  }

  List<Widget> getImgList(){
    List<Widget> result = [];
    result.addAll(imgs);
    result.add(new IconButton(icon: Icon(Icons.add, color: Colors.blue,), onPressed: picImg));
    return result;
  }

  Future<void> picImg() async {
    ImageModule picker = new ImageModule();
    var path = await picker.getImage();
    Image img = new Image.file(File(path), width: 10, height: 10,);
    UtilityModule ctr = new UtilityModule();
    var imgData = await ctr.getImageLatLang(path);

    setState(() {
      imgs.add(img);
      imgs_path.add(path);
      addMarker(LatLng(imgData['lat'], imgData['lang']));
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Card(
          child: Container(
            width: deviceSize.width - 20,
            height: deviceSize.height * 0.5,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              markers: markers,
            ),
          ),
        ),
        SizedBox(
            height: deviceSize.height / 4,
            child: new Card(
                child: GridView.count(
                  padding: EdgeInsets.all(10),
                  crossAxisCount: 4,
                  children: getImgList(),
                )
            )
        ),
      ],
    );
  }

  Future<void> _goToTarget(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition targetPosition = CameraPosition(
        target: pos,
        zoom: 14.5);
    controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }
}
