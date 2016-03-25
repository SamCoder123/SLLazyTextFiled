//
//  ViewController.m
//  SLLazyTextFiled
//
//  Created by halong33 on 16/3/24.
//  Copyright © 2016年 com.halong. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+SLCategory.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *myTextFiled;
//小王子编程之道:在简单的东西也有它的价值.诚邀你一同感受开源的乐趣
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"textFiled内容正确与否:%d",[self.myTextFiled textFiledIsCorrect]);
}

@end
