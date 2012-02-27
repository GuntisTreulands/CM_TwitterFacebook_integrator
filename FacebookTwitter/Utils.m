//
//  NSDateUtil.m
//  friendsNavApp
//
//  Created by Comonitos on 24.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation Utils

+ (void) addCornersToLayer:(CALayer *)layer withSize:(float)size borders:(float)bsize andColor:(UIColor *)color
{
	// Get the Layer of any view
	CALayer * l = layer;
	[l setMasksToBounds:YES];
	[l setCornerRadius:size];
	
	// You can even add a border
	[l setBorderWidth:bsize];
	[l setBorderColor:[color CGColor]];
}


@end























