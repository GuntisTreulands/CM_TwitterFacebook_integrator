//
//  Remote.m
//  friendsNavApp
//
//  Created by Comonitos on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Remote.h"

//TWITTER
#define kOAuthConsumerKey				@""
#define kOAuthConsumerSecret			@""


//FB
static NSString* kAppId = @"";

static Remote * _sharedRemote = nil;

@implementation Remote

@synthesize _facebook,_engine;
@synthesize _isFacebookLoggedIn, _isTwitterLoggedIn;
@synthesize _updatedTw,_updatedFb;
@synthesize fbFriends,twFriends,fbId;


- (BOOL) haveAccesToRemote
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN))
    {
        [self showModalMessage:@"No internet Connection"];

        return NO;
    }
    else 
    {
        return YES;
    }
    
}

//modal message showing
- (void) showModalMessage:(NSString *)mes
{
    popup.label.text = mes;
    [popup show];
}

+ (Remote *) sharedRemote
{
    if (_sharedRemote == nil)
    {
        _sharedRemote = [[Remote alloc] init];
    }
    
    return _sharedRemote;
}

- (id) init
{
    self = [super init];
    if (self) {
        popup = [[PopUp alloc] init];
    }
    
    return self;
}
+ (void)releaseRemote;
{
    [_sharedRemote release];
    _sharedRemote = nil;
}

- (BOOL) isConnectedToFb
{
    if (![_facebook isSessionValid])
    {
        if (!FBPermissions)
            FBPermissions =  [[NSArray arrayWithObjects:
                               @"read_stream",
                               @"read_friendlists",
                               @"publish_stream",
                               @"offline_access",
                               @"email",
                               @"read_mailbox",
                               @"user_location",
                               @"user_birthday",
                               @"friends_about_me",
                               @"friends_birthday",
                               @"friends_likes",
                               @"friends_location",
                               @"friends_status", nil] retain];
        
        if (self._facebook == nil)
        {
            self._facebook = [[[Facebook alloc] initWithAppId:kAppId] autorelease];
        }
        
        self._facebook.accessToken    = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
        self._facebook.expirationDate = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        
        if ([_facebook isSessionValid])
        { 
            return YES;
        } else {
            return NO;
        }
        
    } else {
        return YES;
    }
    
    return NO;
}

- (BOOL) isConnectedToTw
{
    if (!_engine) 
    {    
        self._engine = [[[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self] autorelease];
        self._engine.consumerKey = kOAuthConsumerKey;
        self._engine.consumerSecret = kOAuthConsumerSecret;
    }
    
    if ([_engine isAuthorized])
    {   
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Application lifecycle

- (void) synchronize {    
    //FB
    if (![_facebook isSessionValid])
    {
        if (!FBPermissions)
            FBPermissions =  [[NSArray arrayWithObjects:
                               @"read_stream",
                               @"read_friendlists",
                               @"publish_stream",
                               @"offline_access",
                               @"email",
                               @"read_mailbox",
                               @"user_location",
                               @"user_birthday",
                               @"friends_about_me",
                               @"friends_birthday",
                               @"friends_likes",
                               @"friends_location",
                               @"friends_status", nil] retain];
        
        if (self._facebook == nil)
        {
            self._facebook = [[[Facebook alloc] initWithAppId:kAppId] autorelease];
        }
        
        [self loginFb];
    }
}

#pragma mark - FB
- (void) loginFb
{
    [self._facebook authorize:FBPermissions delegate:self];
}
-(void) logoutFB
{
    [self._facebook logout:self];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ExpirationDate"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDidLogout" object:nil];
}
- (void)fbDidLogin
{
    [[NSUserDefaults standardUserDefaults] setObject:self._facebook.accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:self._facebook.expirationDate forKey:@"ExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self._facebook requestWithGraphPath:@"me" andDelegate:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDidLogin" object:nil];
    
    _isFacebookLoggedIn = YES;
    NSLog(@"FACEBOOK --- Logged In");
}
- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"Didnt Login FACEBOOK");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDidLogout" object:nil];
}


#pragma mark - FBRequestDelegate
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"FB received response %@",response.URL);
}

- (void)request:(FBRequest *)request didLoad:(id)result {

    NSArray *components = [request.url componentsSeparatedByString:@"/"];

    NSString *url = [components objectAtIndex:[components count]-1];

    NSLog(@"%@",url);
    
    if ([url isEqualToString:@"me"])
    {
        if ([result objectForKey:@"email"])
        {
            //use email
        }
    } else if ([result isKindOfClass:[NSData class]])
    {
        //image loaded
        UIImage *img = [UIImage imageWithData:result];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"imageDidFinishLoading" object:img];
        
    } else if ([url isEqualToString:@"friends"])
    {
        fbFriends = [[[NSMutableDictionary alloc] init] autorelease];
        
        NSArray *friends = [result objectForKey:@"data"];
        for (NSDictionary* friend in friends) {
            
            //getting ids and friends names
            [fbFriends setObject:[friend objectForKey:@"id"] forKey:[friend objectForKey:@"name"]];
        }
    } else if ([url isEqualToString:@"inbox"])
    {
        NSArray *messages = [result objectForKey:@"data"];

//for each message
        for (NSDictionary *message in messages) {
            
            
            NSString *messageId = [message objectForKey:@"id"];

            if ([[[message objectForKey:@"to"] objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
            {
                //to friend id
                NSString *toId = [[[message objectForKey:@"to"] objectForKey:@"data"] objectForKey:@"id"];
            } else {

                NSArray *adresses = [[message objectForKey:@"to"] objectForKey:@"data"];
//if there is no address
                if ([adresses count] == 0 )
                { 
//                        NSLog(@"Do nothing");
                } else if ( [adresses count] == 1)
                {
//if adress is simple
                    
                    //mesage
//                    NSString *messageId = [message objectForKey:@"id"];
//                    NSString *parentId = [message objectForKey:@"id"];
//                    NSString *fromId = [[adresses objectAtIndex:0] objectForKey:@"id"];
//                    NSString *toId = fbId;
//                    NSString *data = [message objectForKey:@"message"];
//                    NSString *date = [message objectForKey:@"updated_time"];
                } else if ([adresses count] == 2)
                {
//if there is from - to
                    
                    //message
                    NSMutableArray *adressesM = [NSMutableArray array];
                    
                    for (id object in adresses)
                    {
                        if ([object isKindOfClass:[NSDictionary class]])
                            [adressesM addObject:object];
                    }
                    
                    if ([adressesM count] == 2)
                    {
                        NSString *toId = nil;
                        NSString *fromId = nil;
                        
                        if ([[[adressesM objectAtIndex:0] objectForKey:@"id"] isEqualToString:fbId])
                        {
                            toId = fbId;
                            fromId = [[adresses objectAtIndex:1] objectForKey:@"id"];
                        } else {
                            toId = [[adresses objectAtIndex:0] objectForKey:@"id"];
                            fromId = fbId;
                        }
//                        NSString *messageId = [message objectForKey:@"id"];
//                        NSString *parentId = [message objectForKey:@"id"];
//                        NSString *fromId = [[adresses objectAtIndex:0] objectForKey:@"id"];
//                        NSString *toId = fbId;
//                        NSString *data = [message objectForKey:@"message"];
//                        NSString *date = [message objectForKey:@"updated_time"];
                    }
                } else {
//more than 2 addresses
//                        NSLog(@">2");
                }
            }
        }

    }  else if ([result objectForKey:@"name"]) {
//some user info
        NSString *facebook_id = [NSString stringWithFormat:@"%@",[result objectForKey:@"id"]];
        NSString *friendName = [NSString stringWithFormat:@"%@ %@",[result objectForKey:@"first_name"],[result objectForKey:@"last_name"]];
        NSString *birthsDate = [result objectForKey:@"birthday"];
        
//        if ([result objectForKey:@"email"])
//            NSString *facebook_email = [result objectForKey:@"email"];
//        
//        if ([result objectForKey:@"location"])
//            NSString *facebook_location_id = [[result objectForKey:@"location"] objectForKey:@"id"];
//
//        if ([result objectForKey:@"bio"])
//            NSString *facebook_bio = [result objectForKey:@"bio"];
        
        if ([result objectForKey:@"gender"]) {
            if ([(NSString *)[result objectForKey:@"gender"] isEqualToString:@"male"])
            { NSString *sex = 0; } else { NSString *sex = 1; }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidSelectFbFriend" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookeRequestDidLoad" object:nil];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    //    [self.label setText:[error localizedDescription]];
};


#pragma mark - TWITTER

- (void) loginTW:(UIViewController *)targetController
{
    twitterViewContrller = nil;
    twitterViewContrller = [targetController retain];
    
    if (!_engine) 
    {    
        self._engine = [[[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self] autorelease];
        self._engine.consumerKey = kOAuthConsumerKey;
        self._engine.consumerSecret = kOAuthConsumerSecret;
        
        
        if (![_engine isAuthorized])
        {   
            UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
            
            if (controller) 
                [twitterViewContrller presentModalViewController:controller animated: YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterDidLogin" object:nil];
            NSLog(@"TWITTER - relogin");
        }
    }
    else {
        if (![_engine isAuthorized])
        {   
            UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
            
            if (controller) 
                [twitterViewContrller presentModalViewController:controller animated: YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterDidLogin" object:nil];
        }
    }
}

- (void)logoutTW
{
    [_engine clearAccessToken];
    [_engine clearsCookies];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authName"];
    
    [_engine release];
    _engine=nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterDidLogout" object:nil];
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username 
{
    NSLog(@"data - %@", data);
    NSLog(@"username - %@", username);

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username 
{
	NSLog(@"TWITTER --- Authenicated for %@", username);
    
        _isTwitterLoggedIn = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterDidLogin" object:nil];
    [twitterViewContrller dismissModalViewControllerAnimated:YES];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
    [twitterViewContrller dismissModalViewControllerAnimated:YES];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
    [twitterViewContrller dismissModalViewControllerAnimated:YES];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier
{
    if ([userInfo count]==1){
        //friend
        NSDictionary *user = [userInfo objectAtIndex:0];
        NSLog(@"%@",user);
        
        NSString *twitter_connected = YES;
        NSString *twitter_id = [user objectForKey:@"id"];
        NSString *friendName = [user objectForKey:@"name"];
        NSString *location = [user objectForKey:@"location"];
        NSString *twitter_link = [user objectForKey:@"screen_name"];
        
        if ([[user objectForKey:@"default_profile_image"] isEqualToString:@"false"])
        {
            NSString *urlString = [[user objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            NSURL *url = [NSURL URLWithString:urlString]; 
            UIImage *profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            NSString *havePhoto = YES;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidSelectTwFriend" object:nil];
    } 
        else if ([[userInfo objectAtIndex:0] objectForKey:@"id"])
    {
        //friends
        NSMutableDictionary *twFriends = [[[NSMutableDictionary alloc] init] autorelease];

        for (NSDictionary *twUser in userInfo)
        {
            [twFriends setObject:[twUser objectForKey:@"id"] forKey:[twUser objectForKey:@"name"]];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"twitterRequestDidLoad" object:nil];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    //statuses for friend
    
	NSMutableArray *tweets = [[NSMutableArray alloc] init];

	for(NSDictionary *d in statuses) {
        [d objectForKey:@"id"];
        [[d objectForKey:@"user"] objectForKey:@"id"];
        [d objectForKey:@"created_at"];
        [d objectForKey:@"text"];
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:@"friendTwStatusesDidFinishDownloading" object:nil];
}

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
    
	NSLog(@"Recieved Object: %@", dictionary);
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
    
	NSLog(@"Direct Messages Received: %@", messages);
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
    
	NSLog(@"Misc Info Received: %@", miscInfo);
}


- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
    [twitterViewContrller dismissModalViewControllerAnimated:YES];
}

@end
