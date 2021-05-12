package com.payne.gp_admob;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.widget.RelativeLayout;

import com.mob.adsdk.AdSdk;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.platform.PlatformView;

public class BannerAdView implements PlatformView {

    private EventChannel.EventSink mEventSink;
    private RelativeLayout mContainer;
    private AdSdk.BannerAd mBannerAd;

    public BannerAdView(Context context, BinaryMessenger binaryMessenger, int id, String unitId, float width, float height) {
        EventChannel eventChannel = new EventChannel(binaryMessenger, "com.mob.adsdk/banner_event_" + id);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                mEventSink = eventSink;
            }

            @Override
            public void onCancel(Object o) {
            }
        });

        Activity activity = ((FlutterApplication) context.getApplicationContext()).getCurrentActivity();
        mContainer = new RelativeLayout(context);
        AdSdk.getInstance().loadBannerAd(activity, unitId, mContainer, width, height,
                new AdSdk.BannerAdListener() {
                    @Override
                    public void onAdLoad(String id, AdSdk.BannerAd ad) {
                        // 设置刷新频率，为0或30~120之间的整数，单位秒，0表示不自动轮播，默认30秒
                        ad.setRefreshInterval(30);
                        mBannerAd = ad;

                        Map<String, Object> result = new HashMap<>();
                        result.put("id", id);
                        result.put("event", "onAdLoad");
                        mEventSink.success(result);
                    }

                    @Override
                    public void onAdShow(String id) {
                        Map<String, Object> result = new HashMap<>();
                        result.put("id", id);
                        result.put("event", "onAdShow");
                        mEventSink.success(result);
                    }

                    @Override
                    public void onAdClose(String id) {
                        Map<String, Object> result = new HashMap<>();
                        result.put("id", id);
                        result.put("event", "onAdClose");
                        mEventSink.success(result);
                        mEventSink.endOfStream();
                    }

                    @Override
                    public void onAdClick(String id) {
                        Map<String, Object> result = new HashMap<>();
                        result.put("id", id);
                        result.put("event", "onAdClick");
                        mEventSink.success(result);
                    }

                    @Override
                    public void onError(String id, int code, String message) {
                        Map<String, Object> result = new HashMap<>();
                        result.put("id", id);
                        result.put("event", "onError");
                        result.put("code", code);
                        result.put("message", message);
                        mEventSink.success(result);
                        mEventSink.endOfStream();
                    }
                });
    }

    @Override
    public View getView() {
        return mContainer;
    }

    @Override
    public void dispose() {
        if (null != mBannerAd) {
            mBannerAd.destroy();
            mBannerAd = null;
        }
    }
}
