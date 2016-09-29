//
//  BaseCardView.h
//  StackView
//
//  Created by 朱云 on 9/27/16.
//  Copyright © 2016 qibu. All rights reserved.
//

#import <UIKit/UIKit.h>
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

@class BaseCardView;
@protocol  CardAnimationViewDataSource <NSObject>
- (CGFloat)numberOfVisibleCards;
- (CGFloat)numberOfCards;
/**
 Ask the delegate for a new card to display in the container.
 - parameter number: number that is needed to be displayed.
 - parameter reusedView: the component may provide you with an unused view.
 - returns: correctly configured card view.
 */
- (BaseCardView*)cardNumber:(NSInteger)number reusedView:(BaseCardView*)baseCardView;
@end
@interface BaseCardView : UIView
- (void)contentVisible:(BOOL)visible;
- (void)prepareForReuse;
@end
