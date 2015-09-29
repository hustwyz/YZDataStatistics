//
//  YZDataStatistics.m
//  YZDataStatistics
//
//  Created by WangYunzhen on 15/9/29.
//  Copyright © 2015年 Wang Yunzhen. All rights reserved.
//

#import "YZDataStatistics.h"
#import <UIKit/UIKit.h>

static NSString * const kYZAppUseDays               = @"kYZAppUseDays";
static NSString * const kYZAppContinuousUseDays     = @"kYZAppContinuousUseDays";
static NSString * const kYZAppUseTime               = @"kYZAppUseTime";
static NSString * const kYZAppActivateCount         = @"kYZAppActivateCount";
static NSString * const kYZAppLastEnterDate         = @"kYZAppLastEnterDate";
static NSString * const kYZAppLastExitDate          = @"kYZAppLastExitDate";

@interface YZDataStatistics ()

@property (nonatomic, assign) NSInteger         appUseDays;             // 使用app的天数
@property (nonatomic, assign) NSInteger         appContinuousUseDays;   // 连续使用app的天数
@property (nonatomic, assign) NSInteger         appUseTime;             // app的使用时间，单位秒
@property (nonatomic, assign) NSInteger         appActivateCount;       // app打开的次数

@property (nonatomic, strong) NSDate            *appLastEnterDate;      // 上次打开app的时间
@property (nonatomic, strong) NSDate            *appLastExitDate;       // 上次退出app的时间

@property (nonatomic, strong) NSDate            *appEnterDate;          // 本次app打开的时间
@property (nonatomic, strong) NSDate            *appExitDate;           // 本次app退出的时间
@property (nonatomic, assign) NSTimeInterval    sessionContinueTime;    // 本次app退出的时间

@end

@implementation YZDataStatistics

#pragma mark - 初始化
+ (instancetype)sharedInstance
{
    static YZDataStatistics *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[YZDataStatistics alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _appUseDays = [[NSUserDefaults standardUserDefaults] integerForKey:kYZAppUseDays];
        _appContinuousUseDays = [[NSUserDefaults standardUserDefaults] integerForKey:kYZAppContinuousUseDays];
        _appUseTime = [[NSUserDefaults standardUserDefaults] integerForKey:kYZAppUseTime];
        _appLastEnterDate = [[NSUserDefaults standardUserDefaults] valueForKey:kYZAppLastEnterDate];
        _appLastExitDate = [[NSUserDefaults standardUserDefaults] valueForKey:kYZAppLastExitDate];
        _appActivateCount = [[NSUserDefaults standardUserDefaults] integerForKey:kYZAppActivateCount];
        _sessionContinueTime = 30;
        if (self.appUseDays <= 0) {
            self.appUseDays = 1;
        }
        if (self.appContinuousUseDays <= 0) {
            self.appContinuousUseDays = 1;
        }
        if (self.appActivateCount <= 0) {
            self.appActivateCount = 1;
        }
        
        if (self.appLastEnterDate == nil) {
            self.appLastEnterDate = [NSDate date];
        }
        if (self.appLastExitDate == nil) {
            self.appLastExitDate = [NSDate date];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppEnterForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAppEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

#pragma mark - 设置会话间隔时长
- (void)setSessionContinueTime:(NSTimeInterval)time
{
    _sessionContinueTime = time;
}


#pragma mark - observer callback
- (void)onAppEnterForeground
{
    self.appEnterDate = [NSDate date]; // 本次打开app的时间
    NSTimeInterval timeOnce = 0;
    if ([self.appEnterDate earlierDate:self.appLastExitDate] == self.appLastExitDate) {
        timeOnce = [self.appEnterDate timeIntervalSinceDate:self.appLastExitDate];
    } else {
        self.appLastExitDate = self.appEnterDate;
    }
    if (timeOnce < self.sessionContinueTime) {// 两次的时间不超过间隔（默认30秒）则表示是同一次启动
        return;
    }
    self.appActivateCount++;// 使用次数+1
    NSInteger days = [self daysFromDate:self.appLastExitDate toDate:self.appEnterDate];
    if (days >= 1) { // 如果不是同一日期，则表示是不同的天数
        self.appUseDays++;
        if (days > 1) {
            self.appContinuousUseDays = 1; // 间隔超过一天，则连续天数置为0
        } else {
            self.appContinuousUseDays++; // 如果间隔一天，表示连续两天在使用
        }
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.appUseDays forKey:kYZAppUseDays];
    [[NSUserDefaults standardUserDefaults] setInteger:self.appContinuousUseDays forKey:kYZAppContinuousUseDays];
    [[NSUserDefaults standardUserDefaults] setInteger:self.appActivateCount forKey:kYZAppActivateCount];
}

- (void)onAppEnterBackground
{
    self.appExitDate = [NSDate date];
    if ([self.appExitDate earlierDate:self.appEnterDate] == self.appEnterDate) {
        self.appUseTime += [self.appExitDate timeIntervalSinceDate:self.appEnterDate];
    }
    
    self.appLastEnterDate = self.appEnterDate;
    self.appLastExitDate = self.appExitDate;
    [[NSUserDefaults standardUserDefaults] setInteger:self.appUseTime forKey:kYZAppUseTime];
    [[NSUserDefaults standardUserDefaults] setObject:self.appLastEnterDate forKey:kYZAppLastEnterDate];
    [[NSUserDefaults standardUserDefaults] setObject:self.appLastExitDate forKey:kYZAppLastExitDate];
}

#pragma mark - calculate date
- (NSInteger)daysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_8_0
    NSCalendarUnit units = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
#else
    NSCalendarUnit units = NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
#endif
    
    NSDateComponents *comp1 = [calendar components:units fromDate:startDate];
    NSDateComponents *comp2 = [calendar components:units fromDate:endDate];
    
    [comp1 setHour:0];
    [comp2 setHour:0];
    
    NSDate *date1 = [calendar dateFromComponents:comp1];
    NSDate *date2 = [calendar dateFromComponents:comp2];

#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_8_0
    return [[calendar components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0] day];
#else
    return [[calendar components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0] day];
#endif

}

@end

