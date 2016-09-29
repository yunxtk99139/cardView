//
//  CardAnimationView.m
//  StackView
//
//  Created by 朱云 on 9/27/16.
//  Copyright © 2016 qibu. All rights reserved.
//

#import "CardAnimationView.h"

static CGFloat  animationsSpeed = 0.2;
static CGSize  CardDefaultSize;
static enum panScrollDirection gestureDirection = Up;
@interface CardAnimationView(){
    NSMutableArray* cardArray;
    NSMutableArray* poolCardArray;
    UIPanGestureRecognizer* gestureRecognizer;
    NSInteger currentIndex;
    CATransform3D flipUpTransform3D;
    CATransform3D flipDownTransform3D;
    NSInteger maxVisibleCardCount;
    NSInteger cardCount;
    BaseCardView* gestureTempCard;
}

@end
@implementation CardAnimationView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initUI];
        _cardSize = CGSizeMake(CardDefaultSize.width, CardDefaultSize.height);
    }
    return self;
}
- (void)initUI{
    CardDefaultSize = CGSizeMake(300, 300);
    gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollOnView:)];
    currentIndex = 0;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 1000.0;
  transform =  CATransform3DRotate(transform, 0, 1, 0, 0);
    flipUpTransform3D = transform;
    CATransform3D transform1 = CATransform3DIdentity;
    transform1.m34 = -1.0 / 1000.0;
   transform1 =  CATransform3DRotate(transform1, -M_PI/2, 1, 0, 0);
    flipDownTransform3D = transform1;
    self.userInteractionEnabled = YES;
    maxVisibleCardCount = 0;
    cardCount = 0;
}
- (void)setDataSourceDelegate:(id<CardAnimationViewDataSource>)dataSourceDelegate{
    _dataSourceDelegate = dataSourceDelegate;
    if(dataSourceDelegate){
        [self configure];
    }
}
- (void)setCardSize:(CGSize)cardSize{
    _cardSize = cardSize;
    if(_dataSourceDelegate){
        [self configure];
    }
}
- (void)configure{
    [self configureConstants];
    [self generateCards];
    [self addGestureRecognizer:gestureRecognizer];
    [self relayoutSubViewsAnimated:false removeLast:NO];
}
- (void)configureConstants{
    if(self.dataSourceDelegate){
        maxVisibleCardCount = [self.dataSourceDelegate numberOfVisibleCards];
        cardCount = [self.dataSourceDelegate numberOfCards];
    }
}
- (void)generateCards{
    if (cardArray.count > 0){
        for(UIView* view in cardArray) {
            [view removeFromSuperview];
        }
    }
    cardArray = [[NSMutableArray alloc] init];
    poolCardArray = [[NSMutableArray alloc] init];
    for (int i=0; i< maxVisibleCardCount; i++) {
        UIView* view = [self generateNewCardViewWithIndex:i reusingCardView:nil];
        [self addSubview:view];
        [self applyConstraintsToView:view];
        [cardArray addObject:view];
    }
}
- (void)applyConstraintsToView:(UIView*)view{
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:_cardSize.width]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:_cardSize.height]];
    if(view.superview){
        [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:view.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:0 toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
}
- (BaseCardView*) addNewCardViewWithIndex:(NSInteger)index insertOnRear:(BOOL)rear{
    NSInteger newIndex = rear ? cardArray.count : 0;
    BaseCardView* newView ;
    // Reuse cards
    if(poolCardArray.count > 0) {
        BaseCardView* reusedView = [poolCardArray objectAtIndex:0];
        [poolCardArray removeObjectAtIndex:0];
        newView = [self generateNewCardViewWithIndex:index reusingCardView: reusedView];
    } else {
        newView = [self generateNewCardViewWithIndex:index reusingCardView:nil];
    }
    rear ?[self insertSubview:newView atIndex:newIndex]:[self addSubview:newView];
    rear ? [cardArray addObject:newView] : [cardArray insertObject:newView atIndex:newIndex];
    [self applyConstraintsToView:newView ];
    [self relayoutSubView:newView relativeIndex:(int)newIndex animated: false delay:0 fadeAndDelete:false];
    newView.alpha = rear ? 0.0 : 1.0;
    return newView;
}


- (BaseCardView*)generateNewCardViewWithIndex:(NSInteger)index reusingCardView:(BaseCardView*) cardView{
    if( cardView != nil ){
        cardView.layer.transform = flipUpTransform3D;
        [cardView removeConstraints:cardView.constraints];
        [cardView prepareForReuse];
    }
    BaseCardView* view = [self.dataSourceDelegate cardNumber:index reusedView: cardView];
    view.translatesAutoresizingMaskIntoConstraints = false;
    return view;
}
- (void)reloadData{
    [self configure];
}
- (void)relayoutSubViewsAnimated:(BOOL)animated removeLast:(BOOL)remove{
    for (int index = 0; index< cardArray.count; index++) {
        BOOL shouldDelete = remove && (index == cardArray.count-1);
        CGFloat delay = animated ? 0.1 * index : 0;
        [self relayoutSubView:cardArray[index] relativeIndex:index animated:YES delay:delay fadeAndDelete:shouldDelete];
    }
    if (remove) {
        [cardArray removeLastObject];
    }
}
- (void)relayoutSubView:(BaseCardView*)subView relativeIndex:(int)relativeIndex animated:(BOOL)animated delay:(NSTimeInterval)delay fadeAndDelete:(BOOL)delete{
    CGFloat width = _cardSize.width;
    CGFloat height = _cardSize.height;
    subView.layer.anchorPoint = CGPointMake(0.5, 1);
    subView.layer.zPosition = (CGFloat )(1000 - relativeIndex);
    CGFloat sizeScale = [self calculateWidthScaleForIndex:relativeIndex];
    for (NSLayoutConstraint* constraint in subView.constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondItem == nil){
            constraint.constant = sizeScale * width;
        }
    }
    for (NSLayoutConstraint* constraint in subView.constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeHeight && constraint.secondItem == nil){
            constraint.constant = sizeScale * height;
        }
    }
    for (NSLayoutConstraint* constraint in self.constraints) {
        if( constraint.firstItem == subView && constraint.firstAttribute == NSLayoutAttributeBottom && constraint.secondItem == self ){
            CGFloat subViewHeight = [self calculateWidthScaleForIndex:relativeIndex] * height;
            CGFloat YOffset = [ self calculusYOffsetForIndex:relativeIndex];
            constraint.constant = subViewHeight/2 - YOffset;
        }
    }
    [UIView animateWithDuration:animated ? animationsSpeed : 0 delay:delay options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        subView.alpha = delete ? 0 : [self calculateAlphaForIndex:relativeIndex];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (delete){
            [poolCardArray addObject:subView];
            [subView removeFromSuperview];
        }
    }];
}
//MARK: Helper Methods
//f(x) = k * x + m
- (CGSize)calculateFactorOfFunction:(CGFloat)x1 x2:(CGFloat)x2 y1:( CGFloat)y1 y2:(CGFloat)y2{
    CGFloat k = (y1-y2)/(x1-x2);
    CGFloat m = (x1*y2 - x2*y1)/(x1-x2);
    return CGSizeMake(k, m);
}
- (CGFloat)calculateResult:(CGFloat)x k:(CGFloat)k m:(CGFloat)m{
    return k * x + m;
}
- (CGFloat)calcuteResultWith:(CGFloat)x1 x2:(CGFloat)x2 y1:(CGFloat)y1 y2:(CGFloat)y2 argument:(int)argument{
    CGSize size = [self calculateFactorOfFunction:x1 x2:x2 y1:y1 y2:y2];
    return [ self calculateResult:argument  k:size.width m:size.height];
}

//I set the gap between 0Card and 1st Card is 35, gap between the last two card is 15. These value on iPhone is a little big, you could make it less.
//设定头两个卡片的距离为35，最后两张卡片之间的举例为15。不设定成等距才符合视觉效果。
- (CGFloat) calculusYOffsetForIndex:(int)indexInQueue{
    if (indexInQueue < 1){
        return 0;
    }
    CGFloat sum= 0.0;
    for(int i=1;i<=indexInQueue;i++){
        CGFloat result =[self calcuteResultWith:1 x2:8 y1:15 y2:5  argument:i];
        if (result < 5){
            result = 5.0;
        }
        sum += result;
    }
    return sum;
}

- (CGFloat) calculateWidthScaleForIndex:(int)indexInQueue{
    CGFloat widthBaseScale = 0.88;
    CGFloat  factor = 1;
    if (indexInQueue == 0){
        factor = 1;
    }else{
        factor = [self calculateScaleFactorForIndex:indexInQueue];
    }
    return widthBaseScale * factor;
}

//Zoom out card one by one.
//为符合视觉以及营造景深效果，卡片依次缩小
- (CGFloat) calculateScaleFactorForIndex:(int)indexInQueue{
    if (indexInQueue < 1){
        return 1;
    }
    CGFloat scale = [self calcuteResultWith:1 x2:8 y1:0.95 y2:0.5 argument:indexInQueue];
    if (scale < 0.1){
        scale = 0.1;
    }
    return scale;
}

- (CGFloat) calculateAlphaForIndex:(int)indexInQueue{
    if (indexInQueue < 1){
        return 1;
    }
    CGFloat alpha = [self calcuteResultWith:6 x2:9 y1:1 y2:0.4 argument:indexInQueue ];
    if (alpha < 0.1){
        alpha = 0.1;
    }else if (alpha > 1){
        alpha = 1;
    }
    return alpha;
}

- (BOOL)flipUp{
    if( currentIndex <= 0) {
        return false;
    }
    currentIndex--;
    BaseCardView* newView =[self addNewCardViewWithIndex:currentIndex insertOnRear:false];
    newView.layer.transform = flipDownTransform3D;
    BOOL shouldRemoveLast = cardArray.count > maxVisibleCardCount;
    [UIView animateKeyframesWithDuration:animationsSpeed delay:0 options:UIViewKeyframeAnimationOptionOverrideInheritedOptions animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
            newView.layer.transform = flipUpTransform3D;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.01 animations:^{
            [newView contentVisible:YES ];
        }];

    } completion:^(BOOL finished) {
        [self relayoutSubViewsAnimated:true removeLast: shouldRemoveLast];
    }];
    return YES;
}

/**
 Flips down one card with animation
 
 - returns: if the action was performed or not (out of bounds)
 */
- (BOOL)flipDown{
    if( currentIndex >= cardCount) {
        return false;
    }
    currentIndex++;
    
    BaseCardView* frontView = [cardArray objectAtIndex:0];
    [cardArray removeObjectAtIndex:0];
    NSInteger lastIndex = currentIndex + cardArray.count;
    if( lastIndex < cardCount) {
        [self addNewCardViewWithIndex:lastIndex insertOnRear:YES ];
    }
    [UIView animateKeyframesWithDuration:animationsSpeed*1.5 delay:0 options:UIViewKeyframeAnimationOptionOverrideInheritedOptions animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
            frontView.layer.transform = flipUpTransform3D;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.01 animations:^{
            [frontView contentVisible:false ];
        }];
        
    } completion:^(BOOL finished) {
        [poolCardArray addObject:frontView];
        [frontView removeFromSuperview ];
        [self relayoutSubViewsAnimated:true removeLast: false];
    }];
    return YES;
}

- (void)scrollOnView:(UIPanGestureRecognizer*)gesture{
    CGPoint velocity = [gesture velocityInView:self];
    CGFloat percent = [gesture translationInView:self].y/150;
    CATransform3D flipTransform3D = CATransform3DIdentity;
    flipTransform3D.m34 = -1.0 / 1000.0;
    switch (gesture.state){
        case UIGestureRecognizerStateBegan:
            gestureDirection = velocity.y > 0 ? Down : Up;
            break;
        case UIGestureRecognizerStateChanged:
            if (gestureDirection == Down){ // Flip down
                if( currentIndex >= cardCount-1) {
                    gesture.enabled = false ;// Cancel gesture
                    return;
                }
                BaseCardView* frontView = cardArray[0];
                if(percent>=0.0 && percent < 1.0){
                    flipTransform3D = CATransform3DRotate(flipTransform3D, -M_PI/2 * percent, 1, 0, 0);
                    frontView.layer.transform = flipTransform3D;
                    if (percent >= 0.5){
                        [frontView contentVisible:NO];
                    }else{
                        [frontView contentVisible:YES];
                    }
                }else if(percent >= 1.0){
                    flipTransform3D = CATransform3DRotate(flipTransform3D, -M_PI/2, 1, 0, 0);
                    frontView.layer.transform = flipTransform3D;
                }else{
                    NSLog(@"%f",percent);
                }
                
            } else { // Flip up
                if( currentIndex <= 0) {
                    gesture.enabled = false ;// Cancel gesture
                    return;
                }
                if (gestureTempCard == nil){
                    BaseCardView* newView = [self addNewCardViewWithIndex:currentIndex-1 insertOnRear:false];
                    newView.layer.transform = flipDownTransform3D;
                    gestureTempCard = newView;
                }
                
                if(percent < -1.0){
                    gestureTempCard.layer.transform = CATransform3DIdentity;
                }else if(percent >= -1.0  && percent<= 0){
                    if (percent <= -0.5){
                        [gestureTempCard contentVisible:NO];
                        
                    }else{
                        [gestureTempCard contentVisible:YES];
                    }
                    flipTransform3D = CATransform3DRotate(flipTransform3D, -M_PI/2 * (percent+1.0), 1, 0, 0);
                    gestureTempCard.layer.transform = flipTransform3D;
                }else{
                    NSLog(@"%f",percent);
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            switch (gestureDirection){
                case Down:
                    if(currentIndex >= cardCount-1) {
                        return;
                    }
                    if (percent >= 0.5){
                        currentIndex++;
                        BaseCardView* frontView = [cardArray objectAtIndex:0];
                        [cardArray removeObjectAtIndex:0];
                        CGFloat lastIndex = currentIndex + cardArray.count;
                        if (lastIndex < cardCount){
                            [self addNewCardViewWithIndex:lastIndex insertOnRear: true];
                        }
                        flipTransform3D = CATransform3DRotate(flipTransform3D, -M_PI/2, 1, 0, 0);
                        [UIView animateWithDuration:0.15 animations:^{
                            frontView.layer.transform = flipTransform3D;
                        } completion:^(BOOL finished) {
                            [poolCardArray addObject:frontView];
                            [frontView removeFromSuperview];
                            [self relayoutSubViewsAnimated:YES  removeLast:NO];
                        }];
                    }else{
                        BaseCardView* frontView = cardArray[0];
                        [UIView animateWithDuration:0.2 animations:^{
                            frontView.layer.transform = CATransform3DIdentity;
                        } completion:^(BOOL finished) {
                            
                        }];
                    }
                    break;
                case Up:
                    if(currentIndex <= 0) {
                        return;
                    }
                    if (percent <= -0.5){
                        currentIndex--;
                        BOOL shouldRemoveLast = cardArray.count > maxVisibleCardCount;
                        [UIView animateWithDuration:0.2 animations:^{
                            gestureTempCard.layer.transform = CATransform3DIdentity;
                        } completion:^(BOOL finished) {
                            [self relayoutSubViewsAnimated:true removeLast: shouldRemoveLast];
                            gestureTempCard = nil;
                        }];
                    }else{
                        [UIView animateWithDuration:0.2 animations:^{
                            gestureTempCard.layer.transform = CATransform3DRotate(flipTransform3D, -M_PI/2, 1, 0, 0);
                        } completion:^(BOOL finished) {
                            [poolCardArray addObject:gestureTempCard];
                            [cardArray removeObjectAtIndex:0];
                            [gestureTempCard removeFromSuperview];
                            gestureTempCard = nil;
                        }];
                    }
            }
            break;
        case UIGestureRecognizerStateCancelled: // When cancel reenable gesture
            gesture.enabled = true;
        default:
            NSLog(@"DEFAULT: DO NOTHING");
    }
    
}

@end
