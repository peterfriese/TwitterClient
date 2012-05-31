//
//  FriendsListViewController.h
//  TwitterClient
//
//  Created by Julien Chaumond on 30/05/12.
//  Copyright (c) 2012 itemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface FriendsListViewController : UITableViewController

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) NSArray *friendIds;
@property (strong, nonatomic) NSMutableArray *friends;

@end
