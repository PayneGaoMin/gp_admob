import 'package:flutter/services.dart';

typedef AdCallback = void Function(String id);
typedef AdErrorCallback = void Function(String id, int code, String message);

/// API for showing various types of advertisements
class AdSdk {
  static int _channelId = 0;
  static MethodChannel _methodChannel =
      new MethodChannel("com.mob.adsdk/method");

  /// set user id on login and logout
  static void setUserId(String userId) {
    _methodChannel.invokeMethod("setUserId", {"userId": userId});
  }

  /// show reward video ad
  static void showRewardVideoAd(String unitId,
      {AdCallback onAdLoad,
      AdCallback onAdShow,
      AdCallback onReward,
      AdCallback onAdClick,
      AdCallback onVideoComplete,
      AdCallback onAdClose,
      AdErrorCallback onError}) {
    _methodChannel.invokeMethod(
        "showRewardVideoAd", {"_channelId": ++_channelId, "unitId": unitId});

    EventChannel eventChannel = EventChannel("com.mob.adsdk/event_$_channelId");
    eventChannel.receiveBroadcastStream().listen((event) {
      switch (event["event"]) {
        case "onAdLoad":
          onAdLoad?.call(event["id"]);
          break;

        case "onAdShow":
          onAdShow?.call(event["id"]);
          break;

        case "onReward":
          onReward?.call(event["id"]);
          break;

        case "onAdClick":
          onAdClick?.call(event["id"]);
          break;

        case "onVideoComplete":
          onVideoComplete?.call(event["id"]);
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

  /// show interstitial ad
  static void showInterstitialAd(String unitId,
      {AdCallback onAdLoad,
      AdCallback onAdShow,
      AdCallback onAdClick,
      AdCallback onAdClose,
      AdErrorCallback onError}) {
    _methodChannel.invokeMethod(
        "showInterstitialAd", {"_channelId": ++_channelId, "unitId": unitId});

    EventChannel eventChannel = EventChannel("com.mob.adsdk/event_$_channelId");
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
