//
//  JSGCommentView.m
//  blur_comment
//
//  Created by dai.fengyi on 15/5/15.
//  Copyright (c) 2015年 childrenOurFuture. All rights reserved.
//

#import "BlurCommentViewTwo.h"
#import "UIImageEffects.h"
#import "DSTextView.h"

#define ANIMATE_DURATION    0.3f
#define kMarginWH           10
#define kButtonWidth        50
#define kButtonHeight       30
#define kTextFont           [UIFont systemFontOfSize:14]
#define kTextViewHeight     33
#define kSheetViewHeight   kTextViewHeight+10

@interface BlurCommentViewTwo ()

@property (strong, nonatomic) SuccessBlock success;
@property (weak, nonatomic) id<BlurCommentViewDelegate> delegate;
@property (strong, nonatomic) UIView *sheetView;
@property (strong, nonatomic) DSTextView *commentTextView;
@end
@implementation BlurCommentViewTwo

+ (void)commentshowInView:(UIView *)view success:(SuccessBlock)success delegate:(id <BlurCommentViewDelegate>)delegate
{
    BlurCommentViewTwo *commentView = [[BlurCommentViewTwo alloc] initWithFrame:view.bounds];
    if (commentView) {
        //挡住响应
        commentView.userInteractionEnabled = YES;
        //增加EventResponsor
        [commentView addEventResponsors];
        //block or delegate
        commentView.success = success;
        commentView.delegate = delegate;
        //截图并虚化
        //commentView.image = [UIImageEffects imageByApplyingLightEffectToImage:[commentView snapShot:view]];
        [view addSubview:commentView];
        [view addSubview:commentView.sheetView];
        [commentView.commentTextView becomeFirstResponder];
    }
}
#pragma mark - 外部调用
+ (void)commentshowSuccess:(SuccessBlock)success
{
    [BlurCommentViewTwo commentshowInView:[UIApplication sharedApplication].keyWindow success:success delegate:nil];
}

+ (void)commentshowDelegate:(id<BlurCommentViewDelegate>)delegate
{
    [BlurCommentViewTwo commentshowInView:[UIApplication sharedApplication].keyWindow success:nil delegate:delegate];
}

+ (void)commentshowInView:(UIView *)view success:(SuccessBlock)success
{
    [BlurCommentViewTwo commentshowInView:view success:success delegate:nil];
}

+ (void)commentshowInView:(UIView *)view delegate:(id<BlurCommentViewDelegate>)delegate
{
    [BlurCommentViewTwo commentshowInView:view success:nil delegate:delegate];
}
#pragma mark - 内部调用
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.alpha = 0;
    
    CGRect rect = self.bounds;
    _sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - kSheetViewHeight, rect.size.width, kSheetViewHeight)];
    _sheetView.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(kMarginWH, kMarginWH, kButtonWidth, kButtonHeight);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = kTextFont;
    [cancelButton addTarget:self action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
   // [_sheetView addSubview:cancelButton];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(_sheetView.bounds.size.width - kButtonWidth - kMarginWH, kMarginWH, kButtonWidth, kButtonHeight);
    commentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [commentButton setTitle:@"发送" forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    commentButton.titleLabel.font = kTextFont;
    [commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
//    [_sheetView addSubview:commentButton];
    
    _commentTextView = [[DSTextView alloc] initWithFrame:CGRectMake(kMarginWH, (kSheetViewHeight-kTextViewHeight)/2, rect.size.width - kMarginWH * 2, kTextViewHeight)];
    _commentTextView.text = nil;
    _commentTextView.backgroundColor = [UIColor whiteColor];
    _commentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _commentTextView.delegate = self;
    _commentTextView.placeholder = @"说说你的看法";
    _commentTextView.layer.cornerRadius = 2.5;
    //设置键盘，使换行变为完成字样
    _commentTextView.keyboardType = UIKeyboardAppearanceDefault;
    _commentTextView.returnKeyType = UIReturnKeySend;
    [_sheetView addSubview:_commentTextView];
}

- (UIImage *)snapShot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addEventResponsors
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Botton Action
- (void)cancelComment:(id)sender {
    [_sheetView endEditing:YES];
}
- (void)comment:(id)sender {
    //发送请求
    if (_success) {
        _success(_commentTextView.text);
    }
    if ([_delegate respondsToSelector:@selector(commentDidFinished:)]) {
        [_delegate commentDidFinished:_commentTextView.text];
    }
    [_sheetView endEditing:YES];
}

- (void)dismissCommentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
    [_sheetView removeFromSuperview];
}

#pragma mark  基于UIView点击编辑框以外的虚拟键盘收起
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self.commentTextView isExclusiveTouch]) {
        if (self.commentTextView.text.length == 0)
        {
            NSLog(@"ssssss");
        }
        [self.commentTextView resignFirstResponder];

    }
}

#pragma mark TextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

#pragma mark - Keyboard Notification Action
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSLog(@"%@", aNotification);
    CGFloat keyboardHeight = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 1;
        _sheetView.frame = CGRectMake(0, self.superview.bounds.size.height - _sheetView.bounds.size.height - keyboardHeight, _sheetView.bounds.size.width, kSheetViewHeight);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 0;
        _sheetView.frame = CGRectMake(0, self.superview.bounds.size.height, _sheetView.bounds.size.width, kSheetViewHeight);
    } completion:^(BOOL finished){
        [self dismissCommentView];
    }];
}
@end