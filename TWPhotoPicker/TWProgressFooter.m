//
//  TWProgressFooter.m
//  Pods
//
//  Created by David R on 7/14/2015.
//
//

#import "TWProgressFooter.h"

@implementation TWProgressFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.myActivityIndicator = [ [ UIActivityIndicatorView alloc ] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray ];
        [ self.myActivityIndicator startAnimating ];
        [self addSubview:self.myActivityIndicator];
    }

    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.myActivityIndicator.center = CGPointMake( CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(self.frame)/2.0 );
}

@end
