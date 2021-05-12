package android.src.main.java.com.payne.gp_admob;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class BannerAdViewFactory extends PlatformViewFactory {

    private BinaryMessenger mBinaryMessenger;

    public BannerAdViewFactory(BinaryMessenger binaryMessenger) {
        super(StandardMessageCodec.INSTANCE);
        mBinaryMessenger = binaryMessenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        Map<String, Object> map = (Map<String, Object>) args;
        String unitId = (String) map.get("unitId");
        float width = ((Double) map.get("width")).floatValue();
        float height = ((Double) map.get("height")).floatValue();
        return new BannerAdView(context, mBinaryMessenger, id, unitId, width, height);
    }
}
