//
//  CardAnimationView.h
//  StackView
//
//  Created by 朱云 on 9/27/16.
//  Copyright © 2016 qibu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCardView.h"
NS_OPTIONS(NSInteger, panScrollDirection) {
     Up   = 0,
     Down = 1,
};
@interface CardAnimationView : UIView
@property (nonatomic,assign) CGSize cardSize;
@property (nonatomic,weak) id<CardAnimationViewDataSource> dataSourceDelegate;
- (void)initUI;
@end
