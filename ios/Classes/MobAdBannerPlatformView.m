#import "MobAdBannerPlatformView.h"
#import <ZJSDK/ZJSDK.h>
#import "GpAdmobPlugin.h"

#pragma mark - PlatformView

@interface MobAdBannerPlatformView()<FlutterStreamHandler, ZJBannerAdViewDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ZJBannerAdView *bannerAd;
@property (nonatomic, strong) FlutterResult bannerCallback;

@end

@implementation MobAdBannerPlatformView
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar
{
    if (self = [super init]) {
        
        // 获取参数
        NSString *unitId;
        CGFloat bannerWidth = 0, bannerHeight = 0;
        if ([args isKindOfClass:[NSDictionary class]]) {
            unitId = args[@"unitId"];
            bannerWidth = [args[@"width"] floatValue];
            bannerHeight = [args[@"height"] floatValue];
        }
        
        if (bannerWidth <= 0.0) {
            bannerWidth = [UIScreen mainScreen].bounds.size.width;
            bannerHeight = bannerWidth /6.4;
        }
        
        if (![unitId isKindOfClass:[NSString class]] || unitId.length == 0) {
            unitId = @"b1";
        }
        
        // 加载banner
        _bannerAd = [[ZJBannerAdView alloc] initWithPlacementId:unitId viewController:[GpAdmobPlugin findCurrentShowingViewController] adSize:CGSizeMake(bannerWidth, bannerHeight)];
        _bannerAd.delegate = self;
        // 容器view
        _containerView = [[UIView alloc] initWithFrame:frame];
        _containerView.backgroundColor = [UIColor clearColor];
        
        // 事件通道
        NSString *channelName = [NSString stringWithFormat:@"com.mob.adsdk/banner_event_%lld", viewId];
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:[registrar messenger]];
        [eventChannel setStreamHandler:self];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (nonnull UIView *)view {
    return _containerView;
}

- (FlutterError* _Nullable)onListenWithArguments:(NSString *_Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    NSLog(@"banner event -> listen");
    if (events) {
        self.bannerCallback = events;
    }
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    NSLog(@"banner event -> cancel listen");
    return nil;
}

#pragma mark - BannerAdDelegate

/**
 banner广告加载成功
 */
- (void)zj_bannerAdViewDidLoad:(ZJBannerAdView *)bannerAdView{
    if (self.bannerCallback) {
        self.bannerCallback(@{@"event":@"onAdLoad"});
    }
}

/**
 banner广告加载失败
 */
- (void)zj_bannerAdView:(ZJBannerAdView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error{
    if (self.bannerCallback) {
        self.bannerCallback(@{@"event":@"onAdError"});
        self.bannerCallback = nil;
    }
}


/**
 bannerAdView曝光回调
 */
- (void)zj_bannerAdViewWillBecomVisible:(ZJBannerAdView *)bannerAdView{
    if (self.bannerCallback) {
        self.bannerCallback(@{@"event":@"onAdShow"});
    }
}

/**
 点击banner广告回调
 */
- (void)zj_bannerAdViewDidClick:(ZJBannerAdView *)bannerAdView{
    if (self.bannerCallback) {
        self.bannerCallback(@{@"event":@"onAdClick"});
    }
}

/**
 关闭banner广告详情页回调
 */
- (void)zj_bannerAdViewDidCloseOtherController:(ZJBannerAdView *)bannerAdView{
    if (self.bannerCallback) {
        self.bannerCallback(@{@"event":@"onAdClose"});
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }
}

@end

#pragma mark - PlatformViewFactory

@interface MobAdBannerPlatformViewFactory()
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
@end

@implementation MobAdBannerPlatformViewFactory

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _registrar = registrar;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    return [[MobAdBannerPlatformView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args registrar:_registrar];
}

@end
