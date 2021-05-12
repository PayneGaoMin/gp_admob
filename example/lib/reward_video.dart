import 'package:flutter/material.dart';
import 'package:gp_admob/ad.dart';

class RewardVideoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                onPressed: () {
                  AdSdk.showRewardVideoAd(
                    "J6612802337",
                    onAdLoad: (String id) {
                      print("RewardVideoAd onAdLoad");
                    },
                    onAdShow: (String id) {
                      print("RewardVideoAd onAdShow");
                    },
                    onReward: (String id) {
                      print("RewardVideoAd onReward");
                    },
                    onAdClick: (String id) {
                      print("RewardVideoAd onAdClick");
                    },
                    onVideoComplete: (String id) {
                      print("RewardVideoAd onVideoComplete");
                    },
                    onAdClose: (String id) {
                      print("RewardVideoAd onAdClose");
                    },
                    onError: (String id, int code, String message) {
                      print("RewardVideoAd onError");
                    },
                  );
                },
                child: Text("加载激励视频广告")),
          ],
        ),
      ),
    );
  }
}
