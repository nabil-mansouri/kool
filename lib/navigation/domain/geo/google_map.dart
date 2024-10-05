import 'dart:math';
import 'package:meta/meta.dart';
import 'geometry.dart';

// The full world on google map is available in tiles of 256 px;
// it has a ratio of 156543.03392 (px/m).
const FULL_WORD_PXM = 156543.03392;

/// Get the minimum zoom level for [meters] and [latitude]
/// Tell how much [ratio] on the total [pixels] it tooks
double getMinimumZoomLevelContainingBounds(int meters,
    {@required double latitude,
    @required double ratioOnMap,
    @required double pixels}) {
  if (pixels == 0) {
    return 14; //default zoom
  }
  final metersPerPx = meters * ratioOnMap / pixels;
  //
  if (metersPerPx == 0) {
    return 14; //default zoom
  }
  //https://gis.stackexchange.com/questions/7430/what-ratio-scales-do-google-maps-zoom-levels-correspond-to
  // temp = FULL_WORD_PXM * cos(latitude * pi / 180)
  // metersPerPx = temp / pow(2, zoom)
  final temp = FULL_WORD_PXM * cos(latitude * pi / 180);
  final zoom = log(temp / metersPerPx) / ln2;
  return zoom + 2;
}

double getZoom(int meters,
    {@required double latitude,
    @required double ratioOnMap,
    @required double pixels}) {
  const EARTH_RADIUS = 6378137;
  const GLOBE_WIDTH = 256; // a constant in Google's map projection
  final metersPerPixel = meters * ratioOnMap / pixels;
  final temp1 = cos(latitude * pi / 180) * 2 * pi * EARTH_RADIUS;
  final temp2 = (temp1 / metersPerPixel) / GLOBE_WIDTH;
  final zoom = log(temp2) / ln2;
  return zoom;
}

double getZoomLevel(Bounds bounds, double pixels) {
  const GLOBE_WIDTH = 256; // a constant in Google's map projection
  final west = bounds.southWest.longitude;
  final east = bounds.northEast.longitude;
  var angle = east - west;
  if (angle < 0) {
    angle += 360;
  }
  return log(pixels * 360 / angle / GLOBE_WIDTH) / ln2;
}

int radiusToZoom(int meters,
    {@required double latitude,
    @required double ratioOnMap,
    @required double pixels}) {
  final w = pixels;
  final d = meters * ratioOnMap;
  final zooms = [
    -1,
    21282,
    16355,
    10064,
    5540,
    2909,
    1485,
    752,
    378,
    190,
    95,
    48,
    24,
    12,
    6,
    3,
    1.48,
    0.74,
    0.37,
    0.19
  ];
  var z = 20, m;
  while (zooms[--z] != -1) {
    m = zooms[z] * w;
    if (d < m) {
      break;
    }
  }
  return z;
}

double getBoundsZoomLevel(Bounds bounds,
    {@required double width, @required double height}) {
  const WORLD_DIM_HEIGHT = 256;
  const WORLD_DIM_WIDTH = 256;
  const ZOOM_MAX = 21.0;

  double latRad(lat) {
    var _sin = sin(lat * pi / 180);
    var radX2 = log((1 + _sin) / (1 - _sin)) / 2;
    return max(min(radX2, pi), -pi) / 2;
  }

  double zoom(mapPx, worldPx, fraction) {
    return (log(mapPx / worldPx / fraction) / ln2);
  }

  var ne = bounds.northEast;
  var sw = bounds.southWest;

  var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

  var lngDiff = ne.longitude - sw.longitude;
  var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

  var latZoom = zoom(height, WORLD_DIM_HEIGHT, latFraction);
  var lngZoom = zoom(width, WORLD_DIM_WIDTH, lngFraction);

  return min(latZoom, min(lngZoom, ZOOM_MAX));
}
