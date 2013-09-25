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
@end

@implementation CardView

- (id)initWithFrame:(CGRect)frame :(unsigned short)cardValue :(unsigned short)cardBack :(BOOL)faceDown
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cardValue = cardValue;
        self.cardBack = cardBack;
        self.faceDown = faceDown;
        self.image = [UIImage imageNamed:[self cardFileImageName:cardValue :cardBack :faceDown]];
        CGRect imageFrame;
        imageFrame.origin = frame.origin;
        imageFrame.size = self.image.size;
        self.frame = imageFrame;
    }
    return self;
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
