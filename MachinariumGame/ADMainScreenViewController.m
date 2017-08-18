//
//  ADMainScreenViewController.m
//  MachinariumGame
//
//  Created by Александр on 17.08.17.
//  Copyright © 2017 Александр Дудырев. All rights reserved.
//

#import "ADMainScreenViewController.h"
#import "ADFiledViewController.h"

@interface ADMainScreenViewController ()

@property (nonatomic, strong) UILabel *orderLabel;
@property (nonatomic, strong) UILabel *limitBlocksLabel;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UIStepper *orderStepper;
@property (nonatomic, strong) UIStepper *limitBlocksStepper;
@property (nonatomic, strong) UIStepper *countStepper;

@property (nonatomic, strong) UIButton *startGame;

@end

@implementation ADMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Сторона квадрата";
    self.orderLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Колличество блоков";
    self.limitBlocksLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Колличество полей";
    self.countLabel = label;
    
    [self.view addSubview:self.orderLabel];
    [self.view addSubview:self.limitBlocksLabel];
    [self.view addSubview:self.countLabel];
    
    
    
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    stepper.minimumValue = 3;
    stepper.maximumValue = 10;
    [stepper addTarget:self action:@selector(stepperAction:) forControlEvents:UIControlEventValueChanged];
    self.orderStepper = stepper;
    
    stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    stepper.minimumValue = 1;
    stepper.maximumValue = 10;
    [stepper addTarget:self action:@selector(stepperAction:) forControlEvents:UIControlEventValueChanged];
    self.limitBlocksStepper = stepper;
    
    stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    stepper.minimumValue = 5;
    stepper.maximumValue = 10;
    [stepper addTarget:self action:@selector(stepperAction:) forControlEvents:UIControlEventValueChanged];
    self.countStepper = stepper;
    
    [self.view addSubview:self.orderStepper];
    [self.view addSubview:self.limitBlocksStepper];
    [self.view addSubview:self.countStepper];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:@"Сгенерировать поля" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startGame = button;
    [self.view addSubview:self.startGame];
}

- (void)viewWillLayoutSubviews {
    
    CGRect bounds = self.view.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(100, 10, 10, 10));
    
    CGFloat x = CGRectGetMinX(bounds);
    CGFloat y = CGRectGetMinY(bounds);
    CGFloat width = CGRectGetWidth(bounds) / 3;
    CGFloat height = 50;
    
    self.orderLabel.frame = CGRectMake(x, y, width * 2, height);
    
    y += height;
    self.limitBlocksLabel.frame = CGRectMake(x, y, width * 2, height);
    
    y += height;
    self.countLabel.frame = CGRectMake(x, y, width * 2, height);
    
    y = CGRectGetMinY(bounds);
    x += width * 2;
    self.orderStepper.frame = CGRectMake(x, y, width, height);
    
    y += height;
    self.limitBlocksStepper.frame = CGRectMake(x, y, width, height);
    
    y += height;
    self.countStepper.frame = CGRectMake(x, y, width, height);
    
    y += height;
    x = CGRectGetMinX(bounds);
    width = CGRectGetWidth(bounds);
    self.startGame.frame = CGRectMake(x, y, width, height);
}

- (void) stepperAction:(UIStepper *)stepper {
    
    NSString *text = [NSString stringWithFormat:@" :%.0f", stepper.value];
    UILabel *label = nil;
    
    if ([stepper isEqual:self.orderStepper]) {
        label = self.orderLabel;
        label.text = @"Сторона квадрата";
    }
    if ([stepper isEqual:self.limitBlocksStepper]) {
        label = self.limitBlocksLabel;
        label.text = @"Колличество блоков";
    }
    if ([stepper isEqual:self.countStepper]) {
        label = self.countLabel;
        label.text = @"Колличество полей";
    }
    
    label.text = [label.text stringByAppendingString:text];
}

- (void)startAction:(UIButton *)button {
    
    ADFiledViewController *vc = [[ADFiledViewController alloc] init];
    vc.order = self.orderStepper.value;
    vc.limitBlocks = self.limitBlocksStepper.value;
    vc.countFields = self.countStepper.value;
    vc.view.backgroundColor = [UIColor whiteColor];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

@end
