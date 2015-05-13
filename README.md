# AppDelegateNotifitaion
プッシュ通知クラス。
IOS7,8対応

## install
pod file add    
```
pod 'AppDelegateNotification'
```

### add Notification class
Notification.h   
```
@interface Notification : NSObject<PushNotification> {
}
```

Notification.m   

```
@implementation Notification

-(void) didRegistDeviceToken : (UIApplication *)application deviceToken:(NSString *)token{
    NSLog(@"Success : Regist to APNS.(%@)", token);
}
-(void) didFailRegistDeviceToken : (UIApplication *)application error:(NSError *)error{
    NSLog(@"Error : Fail Regist to APNS.(%@)",error);
}
-(void)setBadge:(UIApplication *)application number:(int)number
{
    if(number >= 1){
        application.applicationIconBadgeNumber = number;
    }else{
        application.applicationIconBadgeNumber = -1;
    }
}
-(void) didPushNotification : (UIApplication *)application userInfo:(NSDictionary *)userInfo{
}
@end
```


### change AppDelegate
AppDelegate.h   

```
@interface AppDelegate : AppDelegateNotification{
}
```

AppDelegate.m

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Notification *push = [[Notification alloc] init];
    [self initNotification:(PushNotificationTypeAlert | PushNotificationTypeBadge | PushNotificationTypeSound | PushNotificationTypeNewsstandContentAvailability) callback:push launchOptions:launchOptions background:TRUE];
    if (IS_SET(launchOptions,UIApplicationLaunchOptionsLocalNotificationKey)) {
        [application scheduleLocalNotification:launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]];
    }
    return YES;
}
```