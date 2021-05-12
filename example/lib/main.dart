import 'package:flutter/material.dart';
import 'banner.dart';
import 'interstitial.dart';
import 'reward_video.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonTheme: ButtonThemeData(minWidth: 200),
      ),
      home: MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/reward-video': (BuildContext context) => RewardVideoPage(),
        '/banner': (BuildContext context) => BannerPage(),
        '/interstitial': (BuildContext context) => InterstitialPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/reward-video');
                },
                child: Text("激励视频广告")),
            RaisedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/banner');
                },
                child: Text("Banner 广告")),
            RaisedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/interstitial');
                },
                child: Text("插屏广告")),
          ],
        ),
      ),
    );
  }
}
