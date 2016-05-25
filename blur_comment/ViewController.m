//
//  ViewController.m
//  blur_comment
//
//  Created by dai.fengyi on 15/5/19.
//  Copyright (c) 2015年 childrenOurFuture. All rights reserved.
//

#import "ViewController.h"
#import "BlurCommentView.h"
#import "BlurCommentViewTwo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 60, 40, 40)];
    [button setTitle:@"评论类型一" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor yellowColor];
    [button addTarget:self action:@selector(commentTypeOne) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)showCommentView:(id)sender {
    [BlurCommentView commentshowSuccess:^(NSString *text) {
        
    }];
}

- (void) commentTypeOne{
    [BlurCommentViewTwo commentshowSuccess:^(NSString *text) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
