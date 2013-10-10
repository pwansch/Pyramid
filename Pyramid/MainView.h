//
//  MainView.h
//  Pyramid
//
//  Created by Peter Wansch on 9/21/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOCARDS         52
#define NOINDEXES       28
#define CXCARD_IPHONE   54
#define CYCARD_IPHONE   72
#define CXCARD_IPAD     71
#define CYCARD_IPAD     96
#define FONT_SIZE_LINE  15

@interface MainView : UIView

@property (assign, nonatomic) BOOL fTurnOverDeck;
@property (assign, nonatomic) BOOL fTimer;
@property (assign, nonatomic) BOOL fPaused;
@property (assign, nonatomic) long lScore;
@property (assign, nonatomic) long lCasinoScore;
@property (assign, nonatomic) unsigned long ulTime;
@property (strong, nonatomic) NSString *text;

- (CGSize)cardSize;
- (CGRect)cardFrame:(unsigned short)cardIndex;
- (CGRect)lineFrame:(unsigned short)lineIndex;
- (void)invalidateLine:(unsigned short)lineIndex;
- (void)invalidateText;
- (void)invalidateStack;
- (CGRect)textFrame;
- (CGRect)stackFrame;
- (CGRect)stackDownFrame;
- (CGRect)downFrame;
- (CGSize)boardSize;
- (CGPoint)offsetPoint;
- (CGFloat)indent;

@end
