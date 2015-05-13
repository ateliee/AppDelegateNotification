//
//  AppDelegateNotification.h
//  AppDelegateNotification
//
//  Created by ateliee on 2015/05/13.
//
//

#ifndef AppDelegateNotification_Header_h
#define AppDelegateNotification_Header_h

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, PushNotificationType) {
    PushNotificationTypeNone    = 0,
    PushNotificationTypeBadge   = 1 << 0,
    PushNotificationTypeSound   = 1 << 1,
    PushNotificationTypeAlert   = 1 << 2,
    PushNotificationTypeNewsstandContentAvailability = 1 << 3,
};

@protocol PushNotification
@required
// device tokenの登録
-(void) didRegistDeviceToken : (UIApplication *)application deviceToken:(NSString *)token;
// device token取得失敗時
-(void) didFailRegistDeviceToken : (UIApplication *)application error:(NSError *)error;
// バッチ数設定
-(void) setBadge : (UIApplication *)application number:(int)number;
// プッシュ通知を取得した際に呼ばれる
-(void) didPushNotification : (UIApplication *)application userInfo:(NSDictionary *)userInfo;

@end

@interface AppDelegateNotification : UIResponder <UIApplicationDelegate>
// 共通データ
@property (strong, nonatomic) UIWindow *window;

@property(strong,nonatomic) NSString* appDeviceToken;
@property(strong,nonatomic) id<PushNotification> notificationCallback;

// APNSへリクエスト
-(BOOL) initNotification:(PushNotificationType) types callback:(id<PushNotification>) callback;
-(BOOL) initNotification:(PushNotificationType) types callback:(id<PushNotification>) callback launchOptions:(NSDictionary *)launchOptions background:(BOOL) background;
// アプリ起動時のプッシュ通知処理
-(void) setLaunchOptions: (NSDictionary *)launchOptions;
// デバイスデータの取得
-(NSDictionary *) getPushNotificationData;

@end

#endif
