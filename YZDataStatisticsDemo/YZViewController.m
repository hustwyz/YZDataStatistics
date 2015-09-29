//
//  ViewController.m
//  YZDataStatistics
//
//  Created by WangYunzhen on 15/9/29.
//  Copyright © 2015年 Wang Yunzhen. All rights reserved.
//

#import "YZViewController.h"
#import "YZDataStatistics.h"

@interface YZViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation YZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.label.lineBreakMode = UILineBreakModeWordWrap;
    self.label.numberOfLines = 0;
    self.label.textColor = [UIColor blueColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    YZDataStatistics *data = [YZDataStatistics sharedInstance];
    NSString *content = [NSString stringWithFormat:@"使用天数\nappUseDays=%zi\n\n连续使用天数\nappContinuousUseDays=%zi\n\n使用总时长\nappUseTime=%zi\n\n启动次数\nappActivateCount=%zi", data.appUseDays, data.appContinuousUseDays, data.appUseTime, data.appActivateCount];
    self.label.text = content;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
