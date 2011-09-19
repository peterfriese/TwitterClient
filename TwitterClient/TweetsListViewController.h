//
//  TweetsListViewController.h
//  TwitterClient
//
//  Created by Peter Friese on 19.09.11.
//  Copyright (c) 2011 itemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface TweetsListViewController : UITableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) id timeline;

@end
