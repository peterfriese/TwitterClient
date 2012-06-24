//
//  TweetsListViewController.h
//  TwitterClient
//
//  Created by Peter Friese on 19.09.11.
//  Copyright (c) 2011, 2012 Peter Friese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TweetComposeViewController.h"
#import "EGORefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>


@interface TweetsListViewController : UITableViewController<TweetComposeViewControllerDelegate, EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (strong, nonatomic) ACAccount *account;
@property (strong, nonatomic) id timeline;

@end
