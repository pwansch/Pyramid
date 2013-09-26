//
//  CardView.h
//  Pyramid
//
//  Created by Peter Wansch on 9/21/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIImageView

@property (assign, nonatomic) unsigned short cardValue;
@property (assign, nonatomic) unsigned short cardBack;
@property (assign, nonatomic) BOOL faceDown;
@property (assign, nonatomic) BOOL tapped;

- (id)initWithFrame:(CGRect)frame :(unsigned short)cardValue :(unsigned short)cardBack :(BOOL)faceDown;
- (void)flipCard;
- (void)tapCard;

@end
