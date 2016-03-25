//
//  UITextField+Category.m
//  MakeThirdPart
//
//  Created by SamLee on 16/1/12.
//  Copyright (c) 2016年 SamLee. All rights reserved.
//

#import "UITextField+SLCategory.h"
#import <objc/runtime.h>

static SLKeyboardToolbar *_toolBar;
static UIButton *_btn;
static UITextField *_textFiled;
#define SL_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface SLKeyboardToolbar ()

@property (nonatomic,strong) UIView *toolbarView;

@property (nonatomic,strong) CALayer *topBorder;

@property (nonatomic, strong) UIButton *button;

+ (instancetype)toolbarWithButton:(UIButton *)button;

@end
@implementation SLKeyboardToolbar

+ (instancetype)toolbarWithButton:(UIButton *)button{
    return [[SLKeyboardToolbar alloc] initWithButton:button];
}

- (id)initWithButton:(UIButton *)button {
    self = [super initWithFrame:CGRectMake(0, 0, self.window.rootViewController.view.bounds.size.width, 40)];
    if (self) {
        _button = button;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:[self inputAccessoryView]];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect frame = _toolbarView.bounds;
    frame.size.height = 0.5f;
    _topBorder.frame = frame;
}

- (UIView *)inputAccessoryView {
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    _toolbarView.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.0];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _topBorder = [CALayer layer];
    _topBorder.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 0.5f);
    _topBorder.backgroundColor = [UIColor colorWithWhite:0.678 alpha:1.0].CGColor;
    [_toolbarView.layer addSublayer:_topBorder];
    [self addButton];
    return _toolbarView;
}

- (void)addButton {
    CGRect originFrame;
    originFrame = CGRectMake(SL_SCREEN_WIDTH-_button.frame.size.width, 0, _button.frame.size.width,_button.frame.size.height);
    _button.frame = originFrame;
    [_toolbarView addSubview:_button];
}

@end
@implementation UIView (SLView)

#pragma mark - Hacking KVC
+ (void)load
{
    SEL originalSelector = @selector(setValue:forKey:);
    SEL swizzledSelector = @selector(sl_setValue:forKey:);
    
    Class class = UIView.class;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)sl_setValue:(id)value forKey:(NSString *)key
{
    NSString *injectedKey = [NSString stringWithUTF8String:sel_getName(@selector(sl_textFiledArr))];
    if ([key isEqualToString:injectedKey]) {
        self.sl_textFiledArr = value;
    } else {
        [self sl_setValue:value forKey:key];
    }
}

- (NSArray *)sl_textFiledArr{
    NSMutableArray *textFiledArr = objc_getAssociatedObject(self, _cmd);
    if (!textFiledArr) {
        textFiledArr = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, textFiledArr, OBJC_ASSOCIATION_RETAIN);
    }
    return textFiledArr;
}

- (void)setSl_textFiledArr:(NSArray *)sl_textFiledArr{
    NSMutableArray *textFiledArr = (NSMutableArray *)self.sl_textFiledArr;
    
    [sl_textFiledArr enumerateObjectsUsingBlock:^(UITextField *textFiled, NSUInteger idx, BOOL *stop) {
        [textFiledArr addObject:textFiled];
    }];
}
@end

@implementation UITextField (SLCategory)

+ (void)load{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    SLKeyboardToolbar *toolBar = [SLKeyboardToolbar toolbarWithButton:btn];
    _toolBar = toolBar;
    _btn = btn;
    SEL originalSelector = @selector(setValue:forKey:);
    SEL swizzledSelector = @selector(sl_setValue:forKey:);
    
    Class class = UIView.class;
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
- (void)sl_setValue:(id)value forKey:(NSString *)key
{
    NSString *injectedKey = [NSString stringWithUTF8String:sel_getName(@selector(sl_textFiledArr))];
    if ([key isEqualToString:injectedKey]) {
        self.sl_textFiledArr = value;
    } else {
        [self sl_setValue:value forKey:key];
    }
}
- (BOOL)textFiledIsCorrect{
    if(self.regexStr){
        if (![self match:self.regexStr withStr:self.text]){
            return NO;
        }else{
            return YES;
        }
    }else{
        if(self.sl_max==0){
            if (self.text.length!=0) {
                return YES;
            }else{
                return NO;
            }
        }else{
            if (self.text.length<self.sl_max+1) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark -键盘即将跳出
-(void)didClickKeyboard:(NSNotification *)sender{
    CGFloat durition = [sender.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyboardRect = [sender.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    [ self.sl_superView.sl_textFiledArr enumerateObjectsUsingBlock:^(UITextField *textFiled, NSUInteger idx, BOOL *stop) {
        if (self==textFiled&&[textFiled isFirstResponder]) {
            [UIView animateWithDuration:durition animations:^{
                float h = 0;
                if (self.sl_superView==self.superview) {
                    h =  self.sl_superView.frame.size.height-textFiled.frame.origin.y-self.frame.size.height;
                }else{
               CGRect superVFrame = [self.superview convertRect:self.frame toView:self.sl_superView];
                    h =  self.sl_superView.frame.size.height-textFiled.frame.origin.y-superVFrame.origin.y-self.frame.size.height;
                }
                if (h>keyboardHeight) {
                    return;
                }
                self.sl_superView.transform = CGAffineTransformMakeTranslation(0, h-keyboardHeight);
            }];
        }
    }];
}

#pragma mark -      当键盘即将消失
-(void)didKboardDisappear:(NSNotification *)sender{
    CGFloat duration = [sender.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.sl_superView.transform = CGAffineTransformIdentity;
    }];
}

- (void)btnAction{
    [self resignFirstResponder];
    if (_textFiled==self.textField) {
    if(self.regexStr){
        if (![self match:self.regexStr withStr:self.text]){
            [self.textField shake];
        }
    }
    }
}

- (BOOL)match:(NSString *)pattern withStr:(NSString *)str
{
    // 1.创建正则表达式
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    return results.count > 0;
}

#pragma mark - Dynamic Properties
- (void)setSl_max:(int)sl_max{
    objc_setAssociatedObject(self, @selector(sl_max), @(sl_max), OBJC_ASSOCIATION_RETAIN);
}

- (int)sl_max{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setMax:(int)max{
    self.sl_max = max;
}

- (void)setSl_regexStr:(NSString *)sl_regexStr{
    objc_setAssociatedObject(self, @selector(sl_regexStr), sl_regexStr, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)sl_regexStr{
    return (NSString *)objc_getAssociatedObject(self, _cmd) ;
}

- (void)setRegexStr:(NSString *)regexStr{
    self.sl_regexStr = regexStr;
}

- (void)setSl_warningAnimation:(BOOL)sl_warningAnimation{
    objc_setAssociatedObject(self, @selector(sl_warningAnimation), @(sl_warningAnimation), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)sl_warningAnimation{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setWarningAnimation:(BOOL)warningAnimation{
    self.sl_warningAnimation = warningAnimation;
}

- (void)setSl_lazyTFOpen:(BOOL)sl_lazyTFOpen{
    objc_setAssociatedObject(self, @selector(sl_lazyTFOpen), @(sl_lazyTFOpen), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)sl_lazyTFOpen{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLazyTFOpen:(BOOL)lazyTFOpen{
    
    if(!lazyTFOpen) {
        [self setTFShowSelfOpen:NO];
        return;
    }
    //lazyTFOpen是yes进行初始化配置
    self.sl_lazyTFOpen = lazyTFOpen;
    [self setUPSelf];
}

- (void)setSl_TFShowSelfOpen:(BOOL)sl_TFShowSelfOpen{
    objc_setAssociatedObject(self, @selector(sl_TFShowSelfOpen), @(sl_TFShowSelfOpen), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)sl_TFShowSelfOpen{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTFShowSelfOpen:(BOOL)TFShowSelfOpen{
    self.sl_TFShowSelfOpen = TFShowSelfOpen;
    if (TFShowSelfOpen) {
        //监听键盘点击
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClickKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didKboardDisappear:) name:UIKeyboardWillHideNotification object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
 
}

- (void)setUPSelf{
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(textDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    self.inputAccessoryView = _toolBar;
    
    self.textField = self;

}

- (UITextField *)textField{
    return objc_getAssociatedObject(self, @selector(textField));
}

- (void)setTextField:(UITextField *)textField{
    objc_setAssociatedObject(self, @selector(textField), textField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)sl_superView{
    return objc_getAssociatedObject(self, @selector(sl_superView));
}

- (void)setSl_superView:(UIView *)sl_superView{
    objc_setAssociatedObject(self, @selector(sl_superView), sl_superView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)textDidBegin:(UITextField *)textField
{
    self.textField = textField;
    _textFiled = textField;
    [_btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self)
    {
        if (textField.text.length > self.sl_max)
        {
            textField.text = [textField.text substringToIndex:self.sl_max];
            if (self.sl_warningAnimation) {
                [self shake];
            }
        }
    }
}

- (void)setSl_rightImage:(UIImage *)sl_rightImage{
    objc_setAssociatedObject(self, @selector(sl_rightImage), sl_rightImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage *)sl_rightImage{
    return objc_getAssociatedObject(self,  _cmd) ;
}

- (void)setRightImage:(UIImage *)rightImage{
        UIImageView *imageView = [[UIImageView alloc]initWithImage:rightImage];
        imageView.frame = CGRectMake(0, 0, 15, 15);
        self.rightView = imageView;
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView.hidden = YES;
}

#pragma mark - Animation
- (void)shake {
    self.rightView.hidden = NO;
    CAKeyframeAnimation *animationKey = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animationKey setDuration:0.5f];
    NSArray *array = [[NSArray alloc] initWithObjects:
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      nil];
    [animationKey setValues:array];
    NSArray *times = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:0.1f],
                      [NSNumber numberWithFloat:0.2f],
                      [NSNumber numberWithFloat:0.3f],
                      [NSNumber numberWithFloat:0.4f],
                      [NSNumber numberWithFloat:0.5f],
                      [NSNumber numberWithFloat:0.6f],
                      [NSNumber numberWithFloat:0.7f],
                      [NSNumber numberWithFloat:0.8f],
                      [NSNumber numberWithFloat:0.9f],
                      [NSNumber numberWithFloat:1.0f],
                      nil];
    [animationKey setKeyTimes:times];
    [self.layer addAnimation:animationKey forKey:@"ViewShake"];
}

- (void)dealloc{
    if (!self.sl_TFShowSelfOpen)return;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end