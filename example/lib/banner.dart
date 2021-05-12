import 'package:flutter/material.dart';
import 'package:gp_admob/banner_ad_view.dart';

class BannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BannerAdView(
              unitId: "zjad_iOS_ZB0001",
              width: 300,
              height: 300 / 6.4,
              onAdLoad: (String id) {
                print("BannerAd onAdLoad");
              },
              onAdShow: (String id) {
                print("BannerAd onAdShow");
              },
              onAdClick: (String id) {
                print("BannerAd onAdClick");
              },
              onAdClose: (String id) {
                print("BannerAd onAdClose");
              },
              onError: (String id, int code, String message) {
                print("BannerAd onError");
              },
            ),
          ],
        ),
      ),
    );
  }
}
