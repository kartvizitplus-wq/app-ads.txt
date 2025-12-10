import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_constants.dart';

class BannerAdContainer extends StatefulWidget {
  const BannerAdContainer({super.key, this.size = AdSize.banner});

  final AdSize size;

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBanner() {
    final ad = BannerAd(
      size: widget.size,
      adUnitId: AdsConstants.bannerUnitId,
      listener: BannerAdListener(onAdFailedToLoad: (ad, error) {
        ad.dispose();
        setState(() => _bannerAd = null);
      }),
      request: const AdRequest(),
    );

    ad.load();
    setState(() => _bannerAd = ad);
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    if (banner == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
