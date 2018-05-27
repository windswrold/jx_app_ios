//
//  AppDelegate.m
//  SmartPurifieriOS
//
//  Created by Wind on 2016/11/14.
//  Copyright © 2016年 SmartPurifieriOS. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager.h>
#import "SPTabbarViewController.h"
#import "SPBaseNavViewController.h"
#import "SPLoginElectricityEntrance.h"
#import "SPUserModel.h"
#import <AlipaySDK/AlipaySDK.h>
#import "SPAppPayManger.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialQQHandler.h"
#import <AFNetworkReachabilityManager.h>
#import "WXApi.h"
#import "SPBaseNetWorkRequst.h"
#import "privateKey.h"
#import <Bugly/Bugly.h>
//#import <JSPatch/JPEngine.h>
#import "UPPaymentControl.h"
#import "SPMainLoginBusiness.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#import "GeTuiSdk.h"
#import "JXMsgPlaySound.h"
#import "JFAreaDataManager.h"
#import "EAIntroView.h"

@interface AppDelegate ()<GeTuiSdkDelegate>

@property (nonatomic,copy) NSString *  downurl;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [[NSUserDefaults standardUserDefaults] initWithSuiteName:@"com.jingxismart.smartpurifier"];
    
    [NSThread sleepForTimeInterval:3];
   
    [self keyboardApplication];
    
    [self UmengShake];
    
    [self configRegisterUserNotificationSettings];
    
    [self configReachability];
    
    [self crashBugly];
    
    [self configGeTuIPush];
    
    application.applicationIconBadgeNumber = 0 ;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[JFAreaDataManager shareManager] areaSqliteDBData];
    
    if ([SPUserModel getUserLoginModel]) {
        
        [self autoBackgroundLogin];
        
        [self  setTabbarWithRootViewC];
    }
    
    return YES;
}

+(void)jx_privateMethod_FullScreenView{

    NSUserDefaults * old = [NSUserDefaults standardUserDefaults];
    
    if (![FETCHCURRENTVERSION isEqualToString:[old objectForKey:FETCHOLDVERSIONKEY]]) {
        
        [old setObject:FETCHCURRENTVERSION forKey:FETCHOLDVERSIONKEY];
        [old synchronize];
        
        EAIntroPage *page1 = [EAIntroPage page];
        
        page1.bgImage = [UIImage imageNamed:@"img_1.png"];
        
        EAIntroPage *page2 = [EAIntroPage page];
        
        page2.bgImage = [UIImage imageNamed:@"img_2.png"];
        
        
        EAIntroPage *page3 = [EAIntroPage page];
        
        page3.bgImage = [UIImage imageNamed:@"img_3.png"];
        
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:[UIScreen mainScreen].bounds andPages:@[page1,page2,page3]];
        
        intro.tapToNext = YES ;
        
        intro.skipButton.hidden = YES ;
        
        intro.pageControl.hidden = YES ;
        
        intro.pageControlY = 42.f;
        
        [intro showFullscreen];
    }
}

-(void)crashBugly{
    
//    [JPEngine startEngine];
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
    
//    BuglyConfig *config = [[BuglyConfig alloc] init];
//#ifdef DEBUG
//    config.hotfixDebugMode = YES;
//    config.debugMode = YES;
//    [Bugly startWithAppId:TentcentBuglyAppID developmentDevice:YES config:config];
//#else
//    config.hotfixDebugMode = NO;
//    
//    [Bugly startWithAppId:TentcentBuglyAppID  config:config];
//#endif
    

    
    BuglyConfig *config = [[BuglyConfig alloc] init];
    
    config.blockMonitorEnable = YES;
    
    config.unexpectedTerminatingDetectionEnable = YES;
    
    [Bugly startWithAppId:TentcentBuglyAppID config:config];
    
    SPUserModel * model  = [SPUserModel getUserLoginModel];
   
    if (model) {
        
        [Bugly setUserIdentifier:[NSString stringWithFormat:@"%@:%@",model.UserPhone,model.userid]];
    }

}

#pragma mark - 没有办法-----
-(void)autoBackgroundLogin{
    

    SPUserModel * user = [SPUserModel getUserLoginModel];
    
    if (user.UserPhone.length>0&&user.password.length>0) {
       
        SPMainLoginBusiness * buins = [[SPMainLoginBusiness alloc] init];
        
        [buins userLogin:@{@"phoneNum":user.UserPhone,@"password":user.password} success:^(id result) {
            
            SPUserModel * model = result ;
            
            model.UserPhone = user.UserPhone;
            
            model.password = user.password;
            
            [GeTuiSdk bindAlias:user.userid andSequenceNum:user.userid];
            
            [model saveUserLoginModel];
            
        } failer:^(NSString *error) {
            
            [SPSVProgressHUD showErrorWithStatus:error];
            
        }];
        
    }

    
}

-(void)UmengShake{

    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:AppkeyWithUmSocial];
    
    // 获取友盟social版本号

    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:AppkeyWithWeChat appSecret:AppSecretWithWeChat redirectURL:@"http://www.szjxzn.cn/index.php"];
    
    
    //设置分享到QQ互联的appKey和appSecret
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:AppkeyWithQQ  appSecret:AppSecretWithQQ redirectURL:@"http://www.szjxzn.cn/index.php"];
    
    //设置新浪的appKey和appSecret
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:AppkeyWithSina  appSecret:AppSecretWithSina redirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
}
/**
 配置键盘管理
 */
-(void)keyboardApplication{

    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    
    manager.enable = YES;////控制整个功能是否启用

    manager.shouldResignOnTouchOutside = YES; //控制点击背景是否收起键盘
    
    manager.shouldToolbarUsesTextFieldTintColor = YES;  //控制键盘上的工具条文字颜色是否用户自定义
    
    manager.enableAutoToolbar = YES; //控制是否显示键盘上的工具条。

    
}


-(void)setTabbarWithRootViewC{

    _tabbar = [[SPTabbarViewController alloc] init];
    
    //SPBaseNavViewController * nav = [[SPBaseNavViewController alloc] initWithRootViewController:tabbar];
    
    self.window.rootViewController = _tabbar;
    
}

-(void)setLoginVCWithRootViewC{

   UIViewController * vc  = [SPLoginElectricityEntrance getLoginViewController];
    
    self.window.rootViewController = vc ;
}

#pragma mark- 配置推送
-(void)configRegisterUserNotificationSettings {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }

}



#pragma mark - 网络监测
-(void)configReachability{

    AFNetworkReachabilityManager * manage = [AFNetworkReachabilityManager sharedManager];
    
    [manage startMonitoring];
}


-(void)configGeTuIPush{

    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
    
    // [ GTSdk ]：自定义渠道
    [GeTuiSdk setChannelId:@"GT-Channel"];
    
    // [ GTSdk ]：使用APPID/APPKEY/APPSECRENT创建个推实例
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    
    
}

#pragma mark - 检查
-(void)checkUpdate
{
    
    // NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    __weak typeof(self) weakself = self;
    //@"type":@"2"   苹果
    [SPBaseNetWorkRequst startNetRequestWithTypeMethod:RequestMethod_POST isNeedUserIdentifier:NO didParam:@{@"ver":@"6",@"type":@"2"} didUrl:@"smvc/launch/test/visit.v" didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSArray class]]) {
        
            NSDictionary * dic  = [response firstObject] ;
            
            if (![dic isEqual:[NSNull null]] && dic) {
                
                [weakself checkParsingAppUpdate:dic];
            }
        }
        
    } didFailed:^(NSString *errorMsg) {
        
        
    }];
    
}

-(void)checkParsingAppUpdate:(NSDictionary*)appInfo{
    //获取当前版本
    NSString *version = FETCHCURRENTVERSION ;
   
    NSString * webVersion = [NSString stringWithFormat:@"%@",[appInfo objectForKey:@"versionCode"]] ;
    
    if ([webVersion isEqualToString:@"(null)"]) {
        
        return;
    }
    
    _downurl = [appInfo objectForKey:@"downurl"];
    
    _downurl = _downurl.length==0?@"https://itunes.apple.com/us/app/jing-xi-zhi-neng/id1189436957?l=zh&ls=1&mt=8":_downurl;
    
    //0 不强制 1 强制
    NSInteger isMustUpdate = [[appInfo objectForKey:@"mustupgrade"] integerValue];
    
//    isMustUpdate = 1;
    
    if (![webVersion isEqualToString:version]) {
        
        if (isMustUpdate==0) {
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"版本更新提示" message:@"为了给您更好的体验，我们建议你使用新的版本。是否更新？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            alert.tag =10;
            
            [alert show];
        }else{
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"版本更新提示" message:@"为了给您更好的体验，我们建议你使用新的版本。是否更新？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            alert.tag=20;
            
            [alert show];
        }
    }

    
}

#pragma mark -UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1&alertView.tag == 10) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_downurl]];
    }
    if (alertView.tag == 20) {
     
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_downurl]];
    }
    
}

//屏幕翻转设置
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    return [self jx_pay_callBackNotification:url];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    return [self jx_pay_callBackNotification:url];
    
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    
    return [self jx_pay_callBackNotification:url];
    
}

-(BOOL) jx_pay_callBackNotification:(NSURL*)url {

    NSLog(@"host %@",url.host);

    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            [SPAppPayManger privatePayCallBack:resultDic type:SP_AppPay_TypeAli ];
            
        }];
        
        return YES;
    }else if ([url.host isEqualToString:@"pay"]){
        
        return [WXApi handleOpenURL:url delegate:[SPAppPayManger shareManger]];
   
    }else if ([url.host isEqualToString:@"uppayresult"]){
        
        [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            
            BOOL result = NO ;
            
            if([code isEqualToString:@"success"]) {
                
                result = YES ;
                
            }
            NSDictionary * dic = @{@"result":[NSNumber numberWithBool:result],@"resultDic":data};
            
            [SPAppPayManger privatePayCallBack:dic type:SP_AppPay_TypeUnionpay ];
            
        }];
        
        return YES;
    }
    else{
        BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
       
        return result;
    }

    
}


#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    // [ GTSdk ]：向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    
    // 控制台打印接收APNs信息
    NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - iOS 10中收到推送消息

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
//    {
//    aps = {
//        sound = default,
//        content-available = 1,
//        alert = 你有一条短消息,
//        mutable-content = 1,
//        category = $由客户端定义,
//        badge = 1
//    },
//    _gmid_ = OSA-0705_jxiILjOkLIA1Zl91mhNCC5:cdc430d1-5dc-15d1065dc61-8457931685:2d18621eb9d25562ad0c9ae0129096dc,
//    _ge_ = 1,
//    _gurl_ = sdk.open.extension.getui.com:8123
//}
    NSLog(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}



#endif

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSLog(@"\n>>[GTSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>[GTSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    
    // 数据转换
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    
    [self addLocalNotification:payloadMsg];
    
    // 控制台打印日志
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@", taskId, msgId, payloadMsg, offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>[GTSdk ReceivePayload]:%@\n\n", msg);
}

-(void)addLocalNotification:(NSString*)notiContent{

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
    
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 内容 [NSString localizedUserNotificationStringForKey:arguments:]
        content.body = [NSString localizedUserNotificationStringForKey:notiContent arguments:nil];
        // app显示通知数量的角标
        content.badge = @(1);
        
        // 通知的提示声音，这里用的默认的声音
        content.sound = [UNNotificationSound defaultSound];
        // 标识符
        content.categoryIdentifier = @"categoryIndentifier";

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"KFGroupNotification" content:content trigger:trigger];

        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"已成功加推送%@",notificationRequest.identifier);
            }
        }];
        
    }else{
        UILocalNotification *local = [[UILocalNotification alloc] init];
        local.alertBody = notiContent;
        local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        local.applicationIconBadgeNumber = 1;
        local.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:local];
    }

     [JXMsgPlaySound initSystemShake];
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // 发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    NSLog(@"\n>>[GTSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // 通知SDK运行状态
    NSLog(@"\n>>[GTSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>[GTSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    
    NSLog(@"\n>>[GTSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}



- (void)applicationWillResignActive:(UIApplication *)application {

    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self checkUpdate];
    
    if ([SPAppPayManger shareManger].infoPayType == SP_AppPay_TypeNone) {
        
        NSLog(@"正常的切换");
        
        
      
        return ;
    }else{
        
        [SPAppPayManger privatePayCallBack:nil type:[SPAppPayManger shareManger].infoPayType ];
    
        NSLog(@"通过支付回来点击左上角恶心的按钮回来");
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
