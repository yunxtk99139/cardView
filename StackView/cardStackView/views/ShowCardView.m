//
//  ShowCardView.m
//  StackView
//
//  Created by 朱云 on 9/28/16.
//  Copyright © 2016 qibu. All rights reserved.
//

#import "ShowCardView.h"

@implementation ShowCardView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_image];
        _image.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}
- (void)contentVisible:(BOOL)visible{
//    _image.alpha = visible ? 1.0:0.0;
}
- (void)prepareForReuse{
//    _image.hidden = NO;
}
@end
