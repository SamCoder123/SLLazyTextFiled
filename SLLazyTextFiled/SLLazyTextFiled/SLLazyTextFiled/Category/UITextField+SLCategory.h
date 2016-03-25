//
//  UITextField+Category.h
//  MakeThirdPart
//
//  Created by SamLee on 16/1/12.
//  Copyright (c) 2016年 SamLee. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (SLView)
@property (nonatomic, copy) IBOutletCollection(UITextField) NSArray *sl_textFiledArr;

@end

@interface SLKeyboardToolbar : UIView


@end


@interface UITextField (SLCategory)
//是否开启懒人版TextFiled
@property (nonatomic, assign, getter=sl_lazyTFOpen) IBInspectable BOOL lazyTFOpen;
@property (nonatomic, assign) BOOL sl_lazyTFOpen;
//是否开启动态躲避键盘遮挡
@property (nonatomic, assign, getter=sl_TFShowSelfOpen) IBInspectable BOOL TFShowSelfOpen;
@property (nonatomic, assign) BOOL sl_TFShowSelfOpen;

@property (nonatomic,assign,getter=sl_max) IBInspectable int max;
@property (nonatomic, assign, getter=sl_warningAnimation) IBInspectable BOOL warningAnimation;

@property (nonatomic, assign) BOOL sl_warningAnimation;
@property (nonatomic, assign) int sl_max;
//正则表达式字符串
@property (nonatomic,copy,getter=sl_regexStr) IBInspectable NSString *regexStr;

@property (nonatomic, copy) NSString *sl_regexStr;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong ,getter=sl_rightImage) IBInspectable UIImage *rightImage;

@property (nonatomic, copy) IBOutlet  UIView *sl_superView;
@property (nonatomic, strong)UIImage *sl_rightImage;

- (BOOL)textFiledIsCorrect;

@end