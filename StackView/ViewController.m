//
//  ViewController.m
//  StackView
//
//  Created by 朱云 on 9/26/16.
//  Copyright © 2016 qibu. All rights reserved.
//

#import "ViewController.h"
#import "CardAnimationView.h"
#import "ShowCardView.h"
@interface ViewController ()<CardAnimationViewDataSource>{
    NSArray* colors;
}
@property (nonatomic,strong) CardAnimationView* cardView;
@end

@implementation ViewController

- (void)viewDidLoad {
    colors = [[NSArray alloc] initWithObjects:[UIColor brownColor],[UIColor grayColor],[UIColor brownColor],[UIColor purpleColor],[UIColor blueColor],[UIColor darkGrayColor],[UIColor redColor],[UIColor whiteColor], nil];
 
    _cardView = [[CardAnimationView alloc] initWithFrame:CGRectMake(30,200 , self.view.frame.size.width-60, self.view.frame.size.height-200)];
    [self.view addSubview:_cardView];
    _cardView.cardSize = CGSizeMake(295,200);
    _cardView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    _cardView.dataSourceDelegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)numberOfVisibleCards{
    return 3;
}
- (CGFloat)numberOfCards{
    return colors.count;
}
- (BaseCardView*)cardNumber:(NSInteger)number reusedView:(BaseCardView*)baseCardView{
    BaseCardView* vi;
    if(!baseCardView){
        vi = [[ShowCardView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    }else{
        vi = baseCardView;
    }
    ((ShowCardView*)vi).image.backgroundColor = colors[number];
       NSLog(@"%@ ",colors[number]);
    vi.layer.shadowRadius = 2;
    vi.layer.shadowOffset = CGSizeMake(0, -2);
    vi.layer.shadowColor = [UIColor blackColor].CGColor;
    vi.layer.cornerRadius = 5;
    vi.layer.masksToBounds = YES;
    return vi;
}
@end
