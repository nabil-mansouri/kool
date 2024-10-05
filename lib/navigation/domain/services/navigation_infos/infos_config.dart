//
const DEFAULT_FREQUENCY = 66; //hertz
//66hertz *15 sec => 1000 times => 999 times to apply change
const CURRENT_WEIGHT_SPEED = 1 / 1000;
//66hertz * 5 sec => 300 times => 299 times to apply change
const CURRENT_WEIGHT_BEARING = 1 / 300;

class NavigationInfosConfig {
  final double finishEpsilon;
  final double cameraPositionRatio;
  final double myPositionRatio;
  final int secondsWindow;
  final double defaultGoogleZoom;
  final double zoomRoundStep;
  final double currentBearingWeight;
  final double currentSpeedWeight;
  const NavigationInfosConfig(
      {this.finishEpsilon = 2,
      this.myPositionRatio = 1 / 6,
      this.cameraPositionRatio = 1 / 2,
      this.secondsWindow = 60,
      this.zoomRoundStep = 0.5,
      this.currentSpeedWeight = CURRENT_WEIGHT_SPEED,
      this.currentBearingWeight = CURRENT_WEIGHT_BEARING,
      this.defaultGoogleZoom = 17});

  double get lastSpeedWeight => 1 - currentSpeedWeight;
  double get lastBearingWeight => 1 - currentBearingWeight;
  double get cameraRatioRelativeToPosition =>
      (cameraPositionRatio - myPositionRatio);
}
