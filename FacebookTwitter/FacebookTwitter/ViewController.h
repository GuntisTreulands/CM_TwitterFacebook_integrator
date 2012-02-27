//
//  ViewController.h
//  FacebookTwitter
//
//  Created by comonitos on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Remote.h"

@interface ViewController : UIViewController
{
    BOOL waitingTwLogin;
    BOOL waitingFbLogin;
    BOOL waitingTwLogout;
    BOOL waitingFbLogout;
    
    BOOL isWaitingFbResponce;
    BOOL isWaitingTwResponce;
    
    NSString *message;
}
@property (retain, nonatomic) IBOutlet UIButton *fbConnect;
@property (retain, nonatomic) IBOutlet UILabel *fbConnectionStatus;
@property (retain, nonatomic) IBOutlet UIButton *twConnect;
@property (retain, nonatomic) IBOutlet UILabel *twConnectionStatus;

- (IBAction) handleFbConnect:(id)sender;
- (IBAction) handleTwConnect:(id)sender;

- (IBAction) handleShareTw:(id)sender;
- (IBAction) handleShareFb:(id)sender;

- (IBAction) checkConnection:(id)sender;

- (void) connected;
- (void) disconnected;

- (void) setFbActive:(BOOL)yes;
- (void) setTwActive:(BOOL)yes;

- (void) loadAccount;
@end
