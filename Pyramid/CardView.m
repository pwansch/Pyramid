//
//  CardView.m
//  Pyramid
//
//  Created by Peter Wansch on 9/21/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import "CardView.h"

@interface CardView ()
  // Class extensions and utility functions
  - (NSString *)cardFileImageName:(unsigned short)cardValue :(unsigned short)cardBack :(BOOL)faceDown;
- (UIImage *)convertImageToNegative:(UIImage *)image;
@end

@implementation CardView

- (UIImage *)convertImageToNegative:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

- (id)initWithFrame:(CGRect)frame :(unsigned short)cardValue :(unsigned short)cardBack :(BOOL)faceDown
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cardValue = cardValue;
        self.cardBack = cardBack;
        self.faceDown = faceDown;
        self.tapped = NO;
        self.image = [UIImage imageNamed:[self cardFileImageName:cardValue :cardBack :faceDown]];
        self.userInteractionEnabled = YES;
        CGRect imageFrame;
        imageFrame.origin = frame.origin;
        imageFrame.size = self.image.size;
        self.frame = imageFrame;
    }
    return self;
}

- (void)tapCard
{
    if (self.tapped) {
        self.tapped = NO;
        self.image = [UIImage imageNamed:[self cardFileImageName:self.cardValue :self.cardBack :self.faceDown]];
    } else {
        self.tapped = YES;
        self.image = [self convertImageToNegative:self.image];
    }
}

- (void)flipCard
{
    if (self.faceDown) {
        self.faceDown = NO;
        self.image = [UIImage imageNamed:[self cardFileImageName:self.cardValue :self.cardBack :self.faceDown]];
    } else {
        self.faceDown = YES;
        self.image = [UIImage imageNamed:[self cardFileImageName:self.cardValue :self.cardBack :self.faceDown]];
    }
}

- (NSString *)cardFileImageName:(unsigned short)cardValue :(unsigned short)cardBack :(BOOL)faceDown
{
    unsigned short index;
    unsigned short offset = 0;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        offset = 100;
    }
    
    if (faceDown) {
        index = offset + 52 + cardBack;
    } else {
        index = offset + cardValue;
    }

    return [NSString stringWithFormat:@"%i.BMP", index];
}

@end
