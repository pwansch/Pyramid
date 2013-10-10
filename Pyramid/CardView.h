//
//  CardView.h
//  Pyramid
//
//  Created by Peter Wansch on 9/21/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _CardPosition {
    Cards = 0,
    Stack = 1,
    StackDown = 2,
    Down = 3
} CardPosition;

@interface CardView : UIImageView

@property (assign, nonatomic) unsigned short cardValue;
@property (assign, nonatomic) unsigned short cardBack;
@property (assign, nonatomic) CardPosition position;
@property (assign, nonatomic) CardPosition previousPosition;
@property (assign, nonatomic) unsigned short positionIndex;
@property (assign, nonatomic) unsigned short previousPositionIndex;
@property (assign, nonatomic) unsigned short indent;
@property (assign, nonatomic) BOOL faceDown;
@property (assign, nonatomic) BOOL previousFaceDown;
@property (assign, nonatomic) BOOL tapped;

- (id)initWithFrame:(CGRect)frame :(unsigned short)cardValue :(unsigned short)cardBack :(BOOL)faceDown :(CardPosition)position :(unsigned short) positionIndex :(BOOL)hidden;
- (void)flipCard;
- (void)tapCard;
- (void)setBack:(unsigned short)back;

@end
