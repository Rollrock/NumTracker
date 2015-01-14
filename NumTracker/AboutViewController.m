//
//  AboutViewController.m
//  NumTracker
//
//  Created by zhuang chaoxiao on 15-1-14.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
- (IBAction)backClicked;
@property (weak, nonatomic) IBOutlet UIView *iconImgView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //_iconImgView.layer.cornerRadius = 8;
    //_iconImgView.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
