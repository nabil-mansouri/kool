import "package:flutter/material.dart";
import 'package:food/multiflow/multiflow.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food/commons/layout_listener.dart';
import 'view_model.dart';

class NavigationPageWidget extends StatelessWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(48.8582, 2.29460),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConnectedScopedModelBuilder<NavigationViewModel>.fromModel(
      model: NavigationViewModel(),
      builder: (context, model) {
        //pas fluide (print + isolate?)
        //pas chargement map en avance
        return Stack(children: <Widget>[
          LayoutListenerGeneric(
              index: 0,
              sizeChanged: (Size size, {Size oldSize}) {
                model.setSize(size);
              },
              child: GoogleMap(
                myLocationEnabled: false,
                //myLocationButtonEnabled: false,
                mapType: MapType.terrain,
                //cameraTargetBounds: ,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  model.setController(controller);
                },
              )),
          Positioned(
            bottom: 45,
            right: 26,
            child: FloatingActionButton(
              heroTag: ("zoomn_in"),
              backgroundColor: Colors.amber,
              child: Icon(
                Icons.zoom_in,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          )
        ]);
      },
    ));
  }
}
