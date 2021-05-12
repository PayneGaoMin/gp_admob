import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ad.dart';

/// Widget for banner ad
class BannerAdView extends StatelessWidget {
  final String unitId;
  final double width;
  final double height;
  final AdCallback onAdLoad;
  final AdCallback onAdShow;
  final AdCallback onAdClick;
  final AdCallback onAdClose;
  final AdErrorCallback onError;

  BannerAdView(
      {Key key,
      this.unitId,
      this.width,
      this.height,
      this.onAdLoad,
      this.onAdShow,
      this.onAdClick,
      this.onAdClose,
      this.onError})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget banner;
    if (defaultTargetPlatform == TargetPlatform.android) {
      banner = AndroidView(
        viewType: 'com.mob.adsdk/banner',
        creationParams: {
          "unitId": unitId,
          "width": width,
          "height": height,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      banner = UiKitView(
        viewType: 'com.mob.adsdk/banner',
        creationParams: {
          "unitId": unitId,
          "width": width,
          "height": height,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      banner = Text("Not supported");
    }

    return Container(
      width: width,
      height: height,
      child: banner,
    );
  }

  void _onPlatformViewCreated(int id) {
    EventChannel eventChannel = EventChannel("com.mob.adsdk/banner_event_$id");
    eventChannel.receiveBroadcastStream().listen((event) {
      switch (event["event"]) {
        case "onAdLoad":
          onAdLoad?.call(event["id"]);
          break;

        case "onAdShow":
          onAdShow?.call(event["id"]);
          break;

        case "onAdClick":
          onAdClick?.call(event["id"]);
          break;

        case "onAdClose":
          onAdClose?.call(event["id"]);
          break;

        case "onError":
          onError?.call(event["id"], event["code"], event["message"]);
          break;
      }
    });
  }
}
