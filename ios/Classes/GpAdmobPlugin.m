#import "GpAdmobPlugin.h"
#import <ZJSDK/ZJSDK.h>
#import "MobAdBannerPlatformView.h"

@interface GpAdmobPlugin()<ZJInterstitialAdDelegate, ZJRewardVideoAdDelegate, FlutterStreamHandler>

@property (nonatomic, strong) ZJRewardVideoAd *rewardVideoAd;
@property (nonatomic, strong) ZJSplashAd *splashAd;
@property (nonatomic, strong) ZJInterstitialAd *intersAd;
@property (nonatomic, strong) FlutterResult callback;
@property (nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property (nonatomic, copy) NSString *userId;
@end


@implementation GpAdmobPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.mob.adsdk/method" binaryMessenger:[registrar messenger]];
    GpAdmobPlugin *instance = [[GpAdmobPlugin alloc] init];
    instance.registrar = registrar;
    [registrar addMethodCallDelegate:instance channel:channel];

    MobAdBannerPlatformViewFactory *f = [[MobAdBannerPlatformViewFactory alloc] initWithRegistrar:registrar];
    [registrar registerViewFactory:f withId:@"com.mob.adsdk/banner"];
}

- (void)dealloc {
    NSLog(@"ad plugin -> dealloc");
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSLog(@"ad plugin -> handleMethodCall:%@, args:%@", call.method, call.arguments);

    // 建立监听
    NSString *channelId = call.arguments[@"_channelId"];
    if ([channelId isKindOfClass:[NSNumber class]]) {
        NSString *channel = [NSString stringWithFormat:@"com.mob.adsdk/event_%@", channelId];
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:channel binaryMessenger:[_registrar messenger]];
        [eventChannel setStreamHandler:self];
    }

    // 调用方法
    if ([call.method isEqualToString:@"setUserId"]) {
        NSString *uid = call.arguments[@"userId"];
        if ([uid isKindOfClass:[NSString class]] && uid.length) {
            self.userId = uid;
        } else {
            self.userId = nil;
        }

    } else if ([call.method isEqualToString:@"showInterstitialAd"]) {
        NSString *groupId = call.arguments[@"unitId"];
        if (![groupId isKindOfClass:[NSString class]] || groupId.length == 0) {
            groupId = @"i1";
        }
        if (self.intersAd != nil) {
            self.intersAd = nil;
        }
        self.intersAd = [[ZJInterstitialAd alloc] initWithPlacementId:groupId delegate:self];
        [self.intersAd loadAd];

    } else if (([call.method isEqualToString:@"showRewardVideoAd"])) {
        NSString *groupId = call.arguments[@"unitId"];
        if (![groupId isKindOfClass:[NSString class]] || groupId.length == 0) {
            groupId = @"rv1";
        }
        // 生成激励视频加载器
        if (self.rewardVideoAd != nil) {
            self.rewardVideoAd = nil;
        }
        self.rewardVideoAd = [[ZJRewardVideoAd alloc] initWithPlacementId:groupId userId:self.userId];
        self.rewardVideoAd.delegate = self;
        [self.rewardVideoAd loadAd];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(NSString *_Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    NSLog(@"ad plugin -> onListen:%@", arguments);
    if (events) {
        self.callback = events;
    }

//    if ([arguments isEqualToString:@"rewardVideo"]) {
//        if (events) {
//            self.rvCallback = events;
//        }
//    } else if ([arguments isEqualToString:@"interstitial"]) {
//        if (events) {
//            self.interCallback = events;
//        }
//    }

    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
    NSLog(@"ad plugin -> onCancelListen:%@", arguments);
    return nil;
}

#pragma mark - ad delegate
- (void) zj_interstitialAdDidLoad:(ZJInterstitialAd*) ad{
    [self.intersAd presentAdFromRootViewController:[self.class findCurrentShowingViewController]];
    if (self.callback) {
        self.callback(@{@"event":@"onAdLoad"});
    }
}

- (void) zj_interstitialAdDidLoadFail:(ZJInterstitialAd*) ad error:(NSError * __nullable)error{
    if (self.callback) {
        self.callback(@{@"event":@"onError"});
        self.callback(FlutterEndOfEventStream);
        self.callback = nil;
    }
}

- (void) zj_interstitialAdDidPresentScreen:(ZJInterstitialAd*) ad{
    if (self.callback) {
        self.callback(@{@"event":@"onAdShow"});
    }
}

- (void) zj_interstitialAdDidClick:(ZJInterstitialAd*) ad{
    if (self.callback) {
        self.callback(@{@"event":@"onAdClick"});
    }
}

- (void) zj_interstitialAdDidClose:(ZJInterstitialAd*) ad{
    if (self.callback) {
        self.callback(@{@"event":@"onAdClose"});
        self.callback(FlutterEndOfEventStream);
        self.callback = nil;
    }
}

- (void) zj_interstitialAdDetailDidClose:(ZJInterstitialAd*) ad{

}

- (void) zj_interstitialAdDidFail:(ZJInterstitialAd*) ad error:(NSError * __nullable)error{
    if (self.callback) {
        self.callback(@{@"event":@"onError"});
        self.callback(FlutterEndOfEventStream);
        self.callback = nil;
    }
}

/**
广告数据加载成功回调

@param rewardedVideoAd ZJRewardVideoAd 实例
*/
- (void)zj_rewardVideoAdDidLoad:(ZJRewardVideoAd *)rewardedVideoAd{
    if (self.callback) {
        self.callback(@{@"event":@"onAdLoad"});
    }
}
/**
视频数据下载成功回调，已经下载过的视频会直接回调

@param rewardedVideoAd ZJRewardVideoAd 实例
*/
- (void)zj_rewardVideoAdVideoDidLoad:(ZJRewardVideoAd *)rewardedVideoAd{
    [self.rewardVideoAd showAdInViewController:[self.class findCurrentShowingViewController]];
    if (self.callback) {
        self.callback(@{@"event":@"onVideoCached"});
    }
}

/**
 视频广告展示

 @param rewardedVideoAd ZJRewardVideoAd 实例
 */
- (void)zj_rewardVideoAdDidShow:(ZJRewardVideoAd *)rewardedVideoAd{
    if (self.callback) {
        self.callback(@{@"event":@"onAdShow"});
    }
}

/**
 视频播放页关闭

 @param rewardedVideoAd ZJRewardVideoAd 实例
 */
- (void)zj_rewardVideoAdDidClose:(ZJRewardVideoAd *)rewardedVideoAd{
    if (self.callback) {
        self.callback(@{@"event":@"onAdClose"});
        self.callback(FlutterEndOfEventStream);
        self.callback = nil;
    }
}

/**
 视频广告信息点击

 @param rewardedVideoAd ZJRewardVideoAd 实例
 */
- (void)zj_rewardVideoAdDidClicked:(ZJRewardVideoAd *)rewardedVideoAd{
    if (self.callback) {
        self.callback(@{@"event":@"onAdClick"});
    }
}


//奖励触发
- (void)zj_rewardVideoAdDidRewardEffective:(ZJRewardVideoAd *)rewardedVideoAd{
    if (self.callback) {
        self.callback(@{@"event":@"onReward"});
    }
}
/**
 视频广告视频播放完成

 @param rewardedVideoAd ZJRewardVideoAd 实例
 */
- (void)zj_rewardVideoAdDidPlayFinish:(ZJRewardVideoAd *)rewardedVideoAd{
    if (self.callback) {
        self.callback(@{@"event":@"onVideoComplete"});
    }
}
/**
 视频广告各种错误信息回调

 @param rewardedVideoAd ZJRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)zj_rewardVideoAd:(ZJRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    if (self.callback) {
        self.callback(@{@"event":@"onError"});
        self.callback(FlutterEndOfEventStream);
        self.callback = nil;
    }
}
// 获取当前显示的 UIViewController
+ (UIViewController *)findCurrentShowingViewController {
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    // 递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }

    return currentShowingVC;
}

@end
