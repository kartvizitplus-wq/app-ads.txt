import 'dart:io';

class AdsConstants {
  const AdsConstants._();

  static const String _androidBanner = 'ca-app-pub-3845151748272408/7298804429';
  static const String _androidInterstitial =
      'ca-app-pub-3845151748272408/9900917039';
  static const String _androidRewardedInterstitial = 'ca-app-pub-384515174827';

  static const String _iosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _iosRewardedInterstitial =
      'ca-app-pub-3940256099942544/6978759866';

  static String get bannerUnitId =>
      Platform.isAndroid ? _androidBanner : _iosBanner;
  static String get interstitialUnitId =>
      Platform.isAndroid ? _androidInterstitial : _iosInterstitial;
  static String get rewardedInterstitialUnitId => Platform.isAndroid
      ? _androidRewardedInterstitial
      : _iosRewardedInterstitial;
}
