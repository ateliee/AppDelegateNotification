//
//  AppDelegateNotification.m
//  AppDelegateNotification
//
//  Created by ateliee on 2015/05/13.
//
//

#import "AppDelegateNotification.h"
#import <objc/runtime.h>

@implementation AppDelegateNotification

NSString* const NotificationKey = @"NKDontThrottleNewsstandContentNotifications";

NSString* const DeviceTokenKey = @"AppDelegate-AppDeviceToken";
NSString* const NotificationCallback = @"AppDelegate-NotificationCallback";

#pragma mark - setter/getter
- (void)setAppDeviceToken:(NSString*)value
{
    objc_setAssociatedObject(self, CFBridgingRetain(DeviceTokenKey), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)appDeviceToken
{
    return objc_getAssociatedObject(self, CFBridgingRetain(DeviceTokenKey));
}
- (void)setNotificationCallback:(NSString*)value
{
    objc_setAssociatedObject(self, CFBridgingRetain(NotificationCallback), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)notificationCallback
{
    return objc_getAssociatedObject(self, CFBridgingRetain(NotificationCallback));
}

#pragma mark - notification method
-(BOOL) initNotification:(PushNotificationType) rtypes callback:(id<PushNotification>) callback{
    return [self initNotification:rtypes callback:callback launchOptions:nil background:FALSE];
}
-(BOOL) initNotification:(PushNotificationType) rtypes callback:(id<PushNotification>) callback launchOptions:(NSDictionary *)launchOptions background:(BOOL) background{
    // 初期化
    [self setAppDeviceToken: nil];
    [self setNotificationCallback: callback];
    // APNsへリクエスト
    // didFinishLaunchingWithOptionsは処理時間が２０秒を超えると強制終了される
    
    if(background){
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
#ifdef __IPHONE_8_0
    UIUserNotificationType types = UIUserNotificationTypeNone;
    if (rtypes & PushNotificationTypeAlert) {
        types |= UIUserNotificationTypeAlert;
    }
    if (rtypes & PushNotificationTypeBadge) {
        types |= UIUserNotificationTypeBadge;
    }
    if (rtypes & PushNotificationTypeSound) {
        types |= UIUserNotificationTypeSound;
    }
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* setting = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType rt = UIRemoteNotificationTypeAlert;
        if(rtypes & PushNotificationTypeBadge){
            rt |= UIRemoteNotificationTypeBadge;
        }
        if(rtypes & PushNotificationTypeAlert) {
            rt |= UIRemoteNotificationTypeAlert;
        }
        if(rtypes & PushNotificationTypeSound) {
            rt |= UIRemoteNotificationTypeSound;
        }
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:rt];
    }
#else
    UIRemoteNotificationType types = UIRemoteNotificationTypeAlert;
    if(rtypes & PushNotificationTypeBadge){
        types |= UIRemoteNotificationTypeBadge;
        pushBadge = TRUE;
    }
    if(rtypes & RushNotificationTypeAlert) {
        types |= UIRemoteNotificationTypeAlert;
        pushAlert = TRUE;
    }
    if(rtypes & PushNotificationTypeSound) {
        types |= UIRemoteNotificationTypeSound;
    }
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
#endif
    // 1日1度までなので、テスト時には下記を有効にする
#ifdef DEBUG
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NotificationKey];
#endif
    
    if (launchOptions) {
        [self setLaunchOptions:launchOptions];
    }
    
    if(background){
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void) setLaunchOptions: (NSDictionary *)launchOptions{
    if (launchOptions) {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil && self.notificationCallback) {
            [self.notificationCallback didPushNotification:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
}

-(NSDictionary *) getPushNotificationData
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    // DeviceTolken
    [params setValue:self.appDeviceToken forKey:@"deviceToken"];
    // Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
    [params setValue:[info objectForKey:@"CFBundleDisplayName"] forKey:@"appName"];
    [params setValue:[info objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
    
    BOOL pushBadge = FALSE;
    BOOL pushAlert = FALSE;
    BOOL pushSound = FALSE;
    if (([[[UIDevice currentDevice] systemVersion] floatValue]) >= 8.0f) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *rntypes = [[UIApplication sharedApplication] currentUserNotificationSettings];
        // Set the defaults to disabled unless we find otherwise...
        if(rntypes.types & UIUserNotificationTypeBadge){
            pushBadge = TRUE;
        }
        if(rntypes.types & UIUserNotificationTypeAlert) {
            pushAlert = TRUE;
        }
        if(rntypes.types & UIUserNotificationTypeSound) {
            pushSound = TRUE;
        }
#else
        NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        // Set the defaults to disabled unless we find otherwise...
        if(rntypes & UIRemoteNotificationTypeBadge){
            pushBadge = TRUE;
        }
        if(rntypes & UIRemoteNotificationTypeAlert) {
            pushAlert = TRUE;
        }
        if(rntypes & UIRemoteNotificationTypeSound) {
            pushSound = TRUE;
        }
#endif
    }else{
        NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        // Set the defaults to disabled unless we find otherwise...
        if(rntypes & UIRemoteNotificationTypeBadge){
            pushBadge = TRUE;
        }
        if(rntypes & UIRemoteNotificationTypeAlert) {
            pushAlert = TRUE;
        }
        if(rntypes & UIRemoteNotificationTypeSound) {
            pushSound = TRUE;
        }
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#else
#endif
    [params setValue:[NSNumber numberWithBool: pushBadge] forKey:@"pushBadge"];
    [params setValue:[NSNumber numberWithBool: pushAlert] forKey:@"pushAlert"];
    [params setValue:[NSNumber numberWithBool: pushSound] forKey:@"pushSound"];
    
    // Get the users Device Model, Display Name, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    [params setValue:dev.name forKey:@"deviceName"];
    [params setValue:dev.model forKey:@"deviceModel"];
    [params setValue:dev.systemVersion forKey:@"deviceSystemVersion"];
    
    return params;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *devToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    // デバイストークンを保存
    [self setAppDeviceToken:devToken];
    
    // デバイストークンの登録
    [self.notificationCallback didRegistDeviceToken:application deviceToken:devToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [self.notificationCallback didFailRegistDeviceToken:application error:error];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
#if !TARGET_IPHONE_SIMULATOR
    
    [self.notificationCallback didPushNotification:application userInfo:userInfo];
    // バックグラウンド起動
    if(application.applicationState == UIApplicationStateInactive){
        //[self clearBadge: application];
        // フォアグランド(起動中)
    }else if(application.applicationState == UIApplicationStateActive){
    }
#endif
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    [self application:application didReceiveRemoteNotification:userInfo];
    // completionHandlerはダウンロードのような時間がかかる処理では非同期に呼ぶ。
    // 同期処理でも呼ばないとログにWarning出力されるので注意。
    //if (application.applicationState != UIApplicationStateActive) {
    completionHandler(UIBackgroundFetchResultNoData);
    //}
}
@end
