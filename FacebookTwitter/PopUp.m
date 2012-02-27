//
//  PopUp.m
//  friendsNavApp
//
//  Created by comonitos on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PopUp.h"
#import "AppDelegate.h"

#define FRAME CGRectMake(0, 0, 320, 480)
#define LABEL_VIEW_FRAME CGRectMake(20, 200, 280, 70)
#define LABEL_FRAME CGRectMake(20, 20, 240, 30)

@implementation PopUp
@synthesize label;

- (id) init 
{
    self = [super initWithFrame:FRAME];
    if (self != nil) {
        self.userInteractionEnabled = NO;
        self.hidden = YES;
        self.alpha = 0;

        labelView = [[UIView alloc] initWithFrame:LABEL_VIEW_FRAME];
        [self setLabelViewSettings];
        label = [[UILabel alloc] initWithFrame:LABEL_FRAME];
        [self setLabelSettings];

        [labelView addSubview:label];
        [label release];
        [self addSubview:labelView];
        [labelView release];

        [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    }
    
    return self;
}
- (void) setLabelSettings
{
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
}
- (void) setLabelViewSettings
{
    labelView.backgroundColor = [UIColor blackColor];
    labelView.alpha = 0.7;
    [Utils addCornersToLayer:labelView.layer withSize:10 borders:3 andColor:[UIColor greenColor]];
}
- (void) show 
{
    sleep(0.1);
    if (self.hidden == NO)
        return;
    
    [[[[UIApplication sharedApplication] delegate] window] bringSubviewToFront:self];

    self.alpha = 0;
    self.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hide)];
        self.alpha = 1;
    [UIView commitAnimations];
}
- (void) hide
{

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideView)];
        self.alpha = 0;
    [UIView commitAnimations];
}
- (void) hideView
{
    self.hidden = YES;
}
@end
