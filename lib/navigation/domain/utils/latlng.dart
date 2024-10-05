class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
  equals(LatLng other) {
    return other?.latitude == latitude && other?.longitude == longitude;
  }
}
