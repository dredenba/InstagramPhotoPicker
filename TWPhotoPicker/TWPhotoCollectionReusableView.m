//
//  TWPhotoCollectionReusableView.m
//  Pods
//
//  Created by Vlado Grancaric on 3/06/2015.
//
//

#import "TWPhotoCollectionReusableView.h"

@implementation TWPhotoCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setImage:[UIImage imageNamed:@"TWPhotoPicker.bundle/left.png"] forState:UIControlStateNormal];
        self.leftButton.frame = CGRectMake(0.0f, 0.f, 60.f, frame.size.height);
        self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(12., 20., 12., 20.);
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMidY(frame), frame.size.width, frame.size.height)];
        self.titleLabel.text = @"All photos";
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.leftButton];
    }
    
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.leftButton.frame = CGRectMake(0.0f, 0.f, 60.0f, CGRectGetHeight(self.frame));
    self.titleLabel.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

@end
