//
//  TweetComposeViewController.m
//  TwitterClient
//
//  Created by Peter Friese on 15.11.11.
//  Copyright (c) 2011, 2012 Peter Friese. All rights reserved.
//

#import "TweetComposeViewController.h"
#import <Twitter/Twitter.h>

@implementation TweetComposeViewController

@synthesize account = _account;
@synthesize tweetComposeDelegate = _tweetComposeDelegate;

@synthesize closeButton;
@synthesize sendButton;
@synthesize textView;
@synthesize titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.titleView.title = [NSString stringWithFormat:@"@%@", self.account.username];    
    [textView setKeyboardType:UIKeyboardTypeTwitter];
    [textView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCloseButton:nil];
    [self setSendButton:nil];
    [self setTextView:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)sendTweet:(id)sender 
{
    NSString *status = self.textView.text;
    
    TWRequest *sendTweet = [[TWRequest alloc] 
                            initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"] 
                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil]
                            requestMethod:TWRequestMethodPOST];
    sendTweet.account = self.account;
    [sendTweet performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultSent];
            });
        }
        else {
            NSLog(@"Problem sending tweet: %@", error);
        }
    }];
}

- (IBAction)cancel:(id)sender
{
    [self.tweetComposeDelegate tweetComposeViewController:self didFinishWithResult:TweetComposeResultCancelled];
}

@end
