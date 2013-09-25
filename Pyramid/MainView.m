//
//  MainView.m
//  Pyramid
//
//  Created by Peter Wansch on 9/21/13.
//  Copyright (c) 2013 Peter Wansch. All rights reserved.
//

#import "MainView.h"

@interface MainView ()

- (CGFloat)gapX;
- (CGFloat)gapY;

@end

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	// Obtain graphics context and set defaults
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    UIFont *font = [UIFont systemFontOfSize:FONT_SIZE_LINE];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *dictionary = @{NSFontAttributeName: font,  NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // Draw the background in green
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f].CGColor);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    // Draw the text
    CGRect rectPaint = [self lineFrame:0];
    if (CGRectIntersectsRect(rectPaint, rect)) {
        NSString *score = [NSString stringWithFormat:@"Score:"];
        [score drawInRect:rectPaint withAttributes:dictionary];
    }
    
    rectPaint = [self lineFrame:1];
    if (CGRectIntersectsRect(rectPaint, rect)) {
        NSString *score;
        if(self.fTimer) {
            score = [NSString stringWithFormat:@"$ %ld", self.lCasinoScore];
        } else {
            score = [NSString stringWithFormat:@"%ld", self.lScore];
        }
        [score drawInRect:rectPaint withAttributes:dictionary];
    }
    
    if (self.fTimer) {
        rectPaint = [self lineFrame:2];
        if (CGRectIntersectsRect(rectPaint, rect)) {
            NSString *score = [NSString stringWithFormat:@"Time:"];
            [score drawInRect:rectPaint withAttributes:dictionary];
        }
        
        rectPaint = [self lineFrame:3];
        if (CGRectIntersectsRect(rectPaint, rect)) {
            NSString *score;
            if (self.fPaused) {
                score = [NSString stringWithFormat:@"Paused"];
            } else {
                unsigned long ulMinutes = self.ulTime / 60;
                unsigned long ulHours = ulMinutes / 60;
                score = [NSString stringWithFormat:@"%lu:%02lu:%02lu", ulHours, ulMinutes - (ulHours * 60), self.ulTime - (ulMinutes * 60) - (ulHours * 3600)];
            }
            [score drawInRect:rectPaint withAttributes:dictionary];
        }
    }
}

- (CGSize)cardSize
{
    CGSize card;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        card.height = CYCARD_IPHONE;
        card.width = CXCARD_IPHONE;
    } else {
        card.height = CYCARD_IPAD;
        card.width = CXCARD_IPAD;
    }
    return card;
}

- (CGFloat)gapY
{
    CGSize cardSize = [self cardSize];
    CGFloat gapY = cardSize.height / 1.5;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            gapY = cardSize.height / 2.8;
        } else {
            gapY = cardSize.height / 1.5;
        }
    }
    
    return gapY;
}

- (CGFloat)gapX
{
    CGFloat gapX = 3;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(orientation)) {
        gapX = -18;
    }
    
    return gapX;
}

- (CGRect)cardFrame:(unsigned short)cardIndex
{
    CGSize cardSize = [self cardSize];
    CGPoint offsetPoint = [self offsetPoint];
    CGFloat gapX = [self gapX];
    CGFloat gapY = [self gapY];
    CGRect rectCardIndex[NOINDEXES] = {
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 3, offsetPoint.y, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 2, offsetPoint.y + gapY, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 3, offsetPoint.y + gapY, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 2, offsetPoint.y + gapY * 2, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 3, offsetPoint.y + gapY * 2, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 4, offsetPoint.y + gapY * 2, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX), offsetPoint.y + gapY * 3, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 2, offsetPoint.y + gapY * 3, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 3, offsetPoint.y + gapY * 3, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 4, offsetPoint.y + gapY * 3, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX), offsetPoint.y + gapY * 4, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 2, offsetPoint.y + gapY * 4, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 3, offsetPoint.y + gapY * 4, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 4, offsetPoint.y + gapY * 4, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 5, offsetPoint.y + gapY * 4, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2), offsetPoint.y + gapY * 5, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX), offsetPoint.y + gapY * 5, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 2, offsetPoint.y + gapY * 5, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 3, offsetPoint.y + gapY * 5, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 4, offsetPoint.y + gapY * 5, cardSize},
        {offsetPoint.x + 20 + (cardSize.width / 2) + (cardSize.width + gapX) * 5, offsetPoint.y + gapY * 5, cardSize},
        {offsetPoint.x + 20, offsetPoint.y + gapY * 6, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX), offsetPoint.y + gapY * 6, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 2, offsetPoint.y + gapY * 6, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 3, offsetPoint.y + gapY * 6, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 4, offsetPoint.y + gapY * 6, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 5, offsetPoint.y + gapY * 6, cardSize},
        {offsetPoint.x + 20 + (cardSize.width + gapX) * 6, offsetPoint.y + gapY * 6, cardSize}};
    return rectCardIndex[cardIndex];
}

- (CGRect)lineFrame:(unsigned short)lineIndex
{
    CGSize cardSize = [self cardSize];
    CGPoint offsetPoint = [self offsetPoint];
    UIFont *font = [UIFont systemFontOfSize:FONT_SIZE_LINE];
    CGRect rectLineIndex[4] = {
        {offsetPoint.x, offsetPoint.y + cardSize.height + font.pointSize * 0.5, cardSize.width, font.pointSize},
        {offsetPoint.x, offsetPoint.y + cardSize.height + font.pointSize * 1.5, cardSize.width, font.pointSize},
        {offsetPoint.x, offsetPoint.y + cardSize.height + font.pointSize * 2.5, cardSize.width, font.pointSize},
        {offsetPoint.x, offsetPoint.y + cardSize.height + font.pointSize * 3.5, cardSize.width, font.pointSize}};
    return rectLineIndex[lineIndex];
}

- (void)invalidateLine:(unsigned short)lineIndex {
    [self setNeedsDisplayInRect:[self lineFrame:lineIndex]];
}

- (CGRect)stackFrame
{
    CGSize cardSize = [self cardSize];
    CGPoint offsetPoint = [self offsetPoint];
    return CGRectMake(offsetPoint.x, offsetPoint.y, cardSize.width, cardSize.height);
}

- (CGRect)stackDownFrame
{
    CGSize cardSize = [self cardSize];
    CGPoint offsetPoint = [self offsetPoint];
    CGFloat gapX = MAX([self gapX], 3);
    return CGRectMake(offsetPoint.x + cardSize.width + gapX, offsetPoint.y, cardSize.width, cardSize.height);
}

- (CGRect)downFrame
{
    CGSize cardSize = [self cardSize];
    CGPoint offsetPoint = [self offsetPoint];
    CGFloat gapX = [self gapX];
    return CGRectMake(offsetPoint.x + (cardSize.width + gapX) * 6 + 40, offsetPoint.y, cardSize.width, cardSize.height);
}

- (CGSize)boardSize
{
    CGSize cardSize = [self cardSize];
    CGFloat gapX = [self gapX];
    CGFloat gapY = [self gapY];
    return CGSizeMake((cardSize.width + gapX) * 6 + cardSize.width + 40, gapY * 6 + cardSize.height);
}

- (CGPoint)offsetPoint
{
    CGSize boardSize = [self boardSize];
    return CGPointMake((self.bounds.size.width - boardSize.width) / 2, (self.bounds.size.height - boardSize.height) / 2);
}

@end