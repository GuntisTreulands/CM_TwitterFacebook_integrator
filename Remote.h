//
//  Remote.h
//  friendsNavApp
//
//  Created by Comonitos on 9/1/11.
//  Copyright 2011 Timothy Kozak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FBConnect.h"
#import "Reachability.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "PopUp.h"

@class SA_OAuthTwitterEngine;

@interface Remote : NSObject
<FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate,
SA_OAuthTwitterControllerDelegate>
{
    PopUp *popup;
    Facebook *_facebook;
    NSArray *FBPermissions;
    
    SA_OAuthTwitterEngine *_engine;
    UIViewController *twitterViewContrller;
    
    BOOL _isFacebookLoggedIn;
    BOOL _isTwitterLoggedIn;
    
    NSDate *_updatedTw;
    NSDate *_updatedFb;
    
    NSMutableDictionary *fbFriends;
    NSMutableDictionary *twFriends;    
    
    
    NSString *fbId;
}
@property (nonatomic, retain) Facebook *_facebook;
@property (nonatomic, retain) SA_OAuthTwitterEngine *_engine;
@property (nonatomic, retain) NSMutableDictionary *fbFriends;
@property (nonatomic, retain) NSMutableDictionary *twFriends;

@property (nonatomic, retain) NSDate *_updatedTw;
@property (nonatomic, retain) NSDate *_updatedFb;

@property BOOL _isFacebookLoggedIn;
@property BOOL _isTwitterLoggedIn;

@property (nonatomic, retain) NSString *fbId;

- (BOOL) haveAccesToRemote;
+ (Remote *) sharedRemote;
+ (void) releaseRemote;

- (void) showModalMessage:(NSString *)mes;

- (void) synchronize;

- (void) loginFb;
- (void) logoutFB;

- (void) loginTW:(UIViewController *)targetController;
- (void) logoutTW;

- (BOOL) isConnectedToFb;
- (BOOL) isConnectedToTw;

@end
