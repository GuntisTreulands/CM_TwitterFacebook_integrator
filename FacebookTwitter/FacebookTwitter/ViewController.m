//
//  ViewController.m
//  FacebookTwitter
//
//  Created by comonitos on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize fbConnect;
@synthesize fbConnectionStatus;
@synthesize twConnect;
@synthesize twConnectionStatus;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    message = @"I'm using @Frendium iPhone App to keep my relationships fresh. http://bit.ly/x8eOt8 #frendium";

	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedFB)  name:@"facebookDidLogin" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedTW)  name:@"twitterDidLogin" object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected)  name:@"twitterDidLogout" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected)  name:@"facebookDidLogout" object:nil];

    
    [self loadAccount];
}

#pragma mark - Handlers
- (IBAction)handleFbConnect:(id)sender {
    waitingFbLogin = YES;
    waitingFbLogout = YES;
    
    if (![[Remote sharedRemote] isConnectedToFb]) {
        [[Remote sharedRemote] loginFb];
    } else {
        [[Remote sharedRemote] logoutFB];
    }
}

- (IBAction)handleTwConnect:(id)sender {
    if (![[Remote sharedRemote] isConnectedToTw])
    {
        waitingTwLogin = YES;
        [[Remote sharedRemote] loginTW:self];
    } else {
        waitingTwLogout = YES;
        [[Remote sharedRemote] logoutTW];
    }
}
#pragma mark - share
- (IBAction)handleShareTw:(id)sender {
    if ([[Remote sharedRemote] isConnectedToTw])
    {
        [[Remote sharedRemote] showModalMessage:@"Shared to TW"];

        [[[Remote sharedRemote] _engine] sendUpdate:message];
        isWaitingTwResponce = NO;
    } else {
        [[Remote sharedRemote] loginTW:self];
        isWaitingTwResponce = YES;

    }
}

- (IBAction)handleShareFb:(id)sender {
    if (![[Remote sharedRemote] isConnectedToFb]) {
        [[Remote sharedRemote] loginFb];
        isWaitingFbResponce = YES;
    } else 
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       message, @"message",
                                       @"Share on Facebook",  @"user_message_prompt",
                                       nil];
        [[[Remote sharedRemote] _facebook] requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:[Remote sharedRemote]];
        
        [[Remote sharedRemote] showModalMessage:@"Shared to FB"];

        isWaitingFbResponce = NO;
    }
}

- (IBAction) checkConnection:(id)sender
{
    if ([[Remote sharedRemote] haveAccesToRemote])
        [[Remote sharedRemote] showModalMessage:@"connected"];
        else 
        [[Remote sharedRemote] showModalMessage:@"not connected"];
}

- (void) connectedTW
{
    [self setTwActive:YES];
    if (isWaitingTwResponce)
        [self handleShareTw:self];
}
- (void) connectedFB
{
    [self setFbActive:YES];
    if (isWaitingFbResponce)
        [self handleShareFb:self];
}

#pragma mark - other
- (void) loadAccount
{
    if ([[Remote sharedRemote] isConnectedToFb])
        [self setFbActive:YES];
    else
        [self setFbActive:NO];
    
    if ([[Remote sharedRemote] isConnectedToTw])
        [self setTwActive:YES];
    else 
        [self setTwActive:NO];
    
}
- (void) connected
{
    if (waitingTwLogin)
    {
        [self setTwActive:YES];
        waitingTwLogin = NO;
    } else if (waitingFbLogin)
    {
        [self setFbActive:YES];
        waitingFbLogin = NO;
        waitingTwLogout = NO;
    }
}
- (void) disconnected
{
    if (waitingTwLogout)
    {
        [self setTwActive:NO];
        waitingTwLogout = NO;
    } else if (waitingFbLogout)
    {
        [self setFbActive:NO];
        waitingFbLogout = NO;
        waitingFbLogin = NO;
    }
}

-(void)setFbActive:(BOOL)yes
{
    if (yes)
    {
        [fbConnect setAlpha:1];
        [fbConnectionStatus setText:@"connected"];
    } else 
    {
        [fbConnect setAlpha:0.5];
        [fbConnectionStatus setText:@"disconnected"];
    }
}
-(void)setTwActive:(BOOL)yes
{
    if (yes)
    {
        [twConnect setAlpha:1];
        [twConnectionStatus setText:@"connected"];
    } else 
    {
        [twConnect setAlpha:0.5];
        [twConnectionStatus setText:@"disconnected"];
    }
}
- (void)dealloc {
    [fbConnect release];
    [twConnect release];
    [twConnectionStatus release];
    [fbConnectionStatus release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTwConnect:nil];
    [self setFbConnect:nil];
    [self setTwConnectionStatus:nil];
    [self setFbConnectionStatus:nil];
    [super viewDidUnload];
}
@end
