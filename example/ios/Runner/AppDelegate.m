#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <ZJSDK/ZJSDK.h>
#import "LaunchPlaceHolder.h"
#import "SplashLogoView.h"

@interface AppDelegate ()<ZJSplashAdDelegate>
@property (nonatomic, strong) ZJSplashAd *splashAd;
@end


@implementation AppDelegate

- (NSObject<FlutterPluginRegistrar>*)registrarForPlugin:(NSString*)pluginKey {
    UIViewController* rootViewController = self.window.rootViewController;
  if ([rootViewController isKindOfClass:[FlutterViewController class]]) {
    return [[(FlutterViewController*)rootViewController pluginRegistry] registrarForPlugin:pluginKey];
  } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
     FlutterViewController *flutterVC = [rootViewController.childViewControllers firstObject];
      if ([flutterVC isKindOfClass:[FlutterViewController class]]) {
        return [[flutterVC pluginRegistry] registrarForPlugin:pluginKey];
      }
  }
  return nil;
}


- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    FlutterViewController *vc = [[FlutterViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    UIWindow *window = [[UIWindow alloc] init];
    window.rootViewController = navi;
    self.window = window;


    // 初始化广告SDK
    [self setupMobADSDK];
    // 显示开屏
    [self showSplashAd:YES];

    // 注册 flutter 插件
    [GeneratedPluginRegistrant registerWithRegistry:self];

    [self.window makeKeyAndVisible];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// 从后台进入App可重新展示开屏
- (void)applicationWillEnterForeground:(UIApplication *)application {
    double last = [[NSUserDefaults standardUserDefaults] doubleForKey:@"AppLastSplashShownTimestamp"];
    double ts = [[NSDate date] timeIntervalSince1970];
    double delt = ts - last;

    NSLog(@"splash -> interval:%lf", delt);

    NSInteger interval = 3 * 60;// 3分钟间隔展示开屏
    if (interval <= 0) {
        return;
    }

    if (delt >= interval) {
        NSLog(@"splash -> should show");
        [self showSplashAd:NO];
    }
}

#pragma mark - 广告SDK

// 初始化广告SDK
- (void)setupMobADSDK {

    [ZJAdSDK registerAppId:@"Z2290733115"];
}

// 调用开屏广告
- (void)showSplashAd:(BOOL)isLaunch {

    // 开屏占位视图(加载开屏广告时的占位视图)
    LaunchPlaceHolder *placeHolder = [LaunchPlaceHolder loadViewFromXib];
    placeHolder.frame = self.window.bounds;
    self.splashAd = [[ZJSplashAd alloc] initWithPlacementId:@"J5271950258"];
    self.splashAd.delegate = self;
    self.splashAd.bottomViewSize = CGSizeMake(self.window.bounds.size.width, floor(self.window.bounds.size.height/4.0));
    self.splashAd.fetchDelay = 5;
    [self.splashAd loadAd];
}

/**
 *  开屏广告素材加载成功
 */
-(void)zj_splashAdDidLoad:(ZJSplashAd *)splashAd{
    // 开屏自定义logo视图(显示在开屏广告底部)
    SplashLogoView *logoView = [SplashLogoView loadViewFromXib];
    logoView.frame = CGRectMake(0, 0, self.window.bounds.size.width, floor(self.window.bounds.size.height/4.0));
    [self.splashAd showAdInWindow:self.window withBottomView:logoView];
}

/**
 *  开屏广告成功展示
 */
-(void)zj_splashAdSuccessPresentScreen:(ZJSplashAd *)splashAd{
    double ts = [[NSDate date] timeIntervalSince1970];
    NSLog(@"splash -> save ts:%lf", ts);
    [[NSUserDefaults standardUserDefaults] setDouble:ts forKey:@"AppLastSplashShownTimestamp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  开屏广告点击回调
 */
- (void)zj_splashAdClicked:(ZJSplashAd *)splashAd{

}

/**
 *  开屏广告关闭回调
 */
- (void)zj_splashAdClosed:(ZJSplashAd *)splashAd{
    self.splashAd = nil;
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)zj_splashAdApplicationWillEnterBackground:(ZJSplashAd *)splashAd{

}

/**
 * 开屏广告倒记时结束
 */
- (void)zj_splashAdCountdownEnd:(ZJSplashAd*)splashAd{

}

/**
 *  开屏广告错误
 */
- (void)zj_splashAdError:(ZJSplashAd *)splashAd withError:(NSError *)error{

}

@end
