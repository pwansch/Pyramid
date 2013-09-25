//
//  MainView.h
//  Pyramid
//
//  Created by Peter Wansch on 9/21/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOINDEXES       28
#define CXCARD_IPHONE   54
#define CYCARD_IPHONE   72
#define CXCARD_IPAD     71
#define CYCARD_IPAD     96
#define FONT_SIZE_LINE  12

@interface MainView : UIView

@property (assign, atomic) BOOL fTimer;
@property (assign, atomic) BOOL fPaused;
@property (assign, atomic) long lScore;
@property (assign, atomic) long lCasinoScore;
@property (assign, atomic) unsigned long ulTime;

- (CGSize)cardSize;
- (CGRect)cardFrame:(unsigned short)cardIndex;
- (CGRect)lineFrame:(unsigned short)lineIndex;
- (void)invalidateLine:(unsigned short)lineIndex;
- (CGRect)stackFrame;
- (CGRect)stackDownFrame;
- (CGRect)downFrame;
- (CGSize)boardSize;
- (CGPoint)offsetPoint;

@end
