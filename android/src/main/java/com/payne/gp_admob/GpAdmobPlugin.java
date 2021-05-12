package com.payne.gp_admob;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;

import com.mob.adsdk.AdSdk;
import com.payne.gp_admob.util.DensityUtils;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** GpAdmobPlugin */
public class GpAdmobPlugin implements FlutterPlugin, MethodCallHandler , ActivityAware {
  private FlutterApplication mApp;
  private Activity mActivity;
  private BinaryMessenger mBinaryMessenger;
  private MethodChannel mMethodChannel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    mApp = (FlutterApplication) binding.getApplicationContext();
    mBinaryMessenger = binding.getBinaryMessenger();
    mMethodChannel = new MethodChannel(mBinaryMessenger, "com.mob.adsdk/method");
    mMethodChannel.setMethodCallHandler(this);

    binding.getPlatformViewRegistry().registerViewFactory("com.mob.adsdk/banner", new BannerAdViewFactory(mBinaryMessenger));
  }

  public static void registerWith(Registrar registrar) {
    GpAdmobPlugin plugin = new GpAdmobPlugin();
    plugin.mApp = (FlutterApplication) registrar.context().getApplicationContext();
    plugin.mBinaryMessenger = registrar.messenger();
    plugin.mMethodChannel = new MethodChannel(registrar.messenger(), "com.mob.adsdk/method");
    plugin.mMethodChannel.setMethodCallHandler(plugin);

    registrar.platformViewRegistry().registerViewFactory("com.mob.adsdk/banner", new BannerAdViewFactory(plugin.mBinaryMessenger));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    mMethodChannel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    mActivity = binding.getActivity();
    mApp.setCurrentActivity(mActivity);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    mActivity = null;
    mApp.setCurrentActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    mActivity = binding.getActivity();
    mApp.setCurrentActivity(mActivity);
  }

  @Override
  public void onDetachedFromActivity() {
    mActivity = null;
    mApp.setCurrentActivity(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "setUserId":
        AdSdk.getInstance().setUserId(call.argument("userId"));
        break;

      case "showRewardVideoAd":
        callMethod(call.argument("_channelId"), s -> showRewardVideoAd(mActivity, call.argument("unitId"), s));
        break;

      case "showInterstitialAd":
        callMethod(call.argument("_channelId"), s -> showInterstitialAd(mActivity, call.argument("unitId"), s));
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  private void callMethod(Integer channelId, final Consumer<EventChannel.EventSink> consumer) {
    EventChannel eventChannel = new EventChannel(mBinaryMessenger, "com.mob.adsdk/event_" + channelId);
    eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o, EventChannel.EventSink eventSink) {
        consumer.accept(eventSink);
      }

      @Override
      public void onCancel(Object o) {
      }
    });
  }

  private void showRewardVideoAd(Activity activity, String unitId, final EventChannel.EventSink eventSink) {
    AdSdk.getInstance().loadRewardVideoAd(activity, unitId, false,
            new AdSdk.RewardVideoAdListener() {
              @Override
              public void onAdLoad(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onAdLoad");
                eventSink.success(result);
              }

              @Override
              public void onVideoCached(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onVideoCached");
                eventSink.success(result);
              }

              @Override
              public void onAdShow(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onAdShow");
                eventSink.success(result);
              }

              /** 视频广告播完验证奖励有效性回调，建议在此回调给用户奖励 */
              @Override
              public void onReward(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onReward");
                eventSink.success(result);
              }

              @Override
              public void onAdClick(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onAdClick");
                eventSink.success(result);
              }

              @Override
              public void onVideoComplete(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onVideoComplete");
                eventSink.success(result);
              }

              @Override
              public void onAdClose(String id) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onAdClose");
                eventSink.success(result);
                eventSink.endOfStream();
              }

              @Override
              public void onError(String id, int code, String message) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", id);
                result.put("event", "onError");
                result.put("code", code);
                result.put("message", message);
                eventSink.success(result);
                eventSink.endOfStream();
              }
            });
  }

  private void showInterstitialAd(Activity activity, String unitId, final EventChannel.EventSink eventSink) {
    float screenWidth = DensityUtils.getScreenWidth(activity);
    float padding = 50;
    float width = DensityUtils.px2dip(activity, screenWidth) - padding * 2;

    AdSdk.getInstance().loadInterstitialAd(activity, unitId, width, new AdSdk.InterstitialAdListener() {
      @Override
      public void onAdLoad(String id) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", id);
        result.put("event", "onAdLoad");
        eventSink.success(result);
      }

      @Override
      public void onAdShow(String id) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", id);
        result.put("event", "onAdShow");
        eventSink.success(result);
      }

      @Override
      public void onAdClose(String id) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", id);
        result.put("event", "onAdClose");
        eventSink.success(result);
        eventSink.endOfStream();
      }

      @Override
      public void onAdClick(String id) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", id);
        result.put("event", "onAdClick");
        eventSink.success(result);
      }

      @Override
      public void onError(String id, int code, String message) {
        Map<String, Object> result = new HashMap<>();
        result.put("id", id);
        result.put("event", "onError");
        result.put("code", code);
        result.put("message", message);
        eventSink.success(result);
        eventSink.endOfStream();
      }
    });
  }
}
