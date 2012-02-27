//
//  PopUp.h
//  friendsNavApp
//
//  Created by comonitos on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@interface PopUp : UIView
{
    UIView *labelView;
    UILabel *label;
}
@property (nonatomic, retain) UILabel *label;
- (void) setLabelSettings;
- (void) setLabelViewSettings;

- (void) show;
- (void) hide;
- (void) hideView;
@end
