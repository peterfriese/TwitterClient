//
//  AccountsListViewController.m
//  TwitterClient
//
//  Created by Peter Friese on 19.09.11.
//  Copyright (c) 2011 itemis. All rights reserved.
//

#import "AccountsListViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TweetsListViewController.h"

@interface AccountsListViewController (private)
- (void)fetchData;
@end

@implementation AccountsListViewController

@synthesize accounts = _accounts;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    self.title = @"Accounts";
    if (self) {
        [self fetchData];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Data handling

- (void)fetchData
{
    if (_accounts == nil) {
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *accountTypeTwitter = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [store requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.accounts = [store accountsWithAccountType:accountTypeTwitter];
                    [self.tableView reloadData]; 
                });
            }
        }];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    ACAccount *account = [self.accounts objectAtIndex:[indexPath row]];
    cell.textLabel.text = account.username;
    cell.detailTextLabel.text = account.accountDescription;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    TWRequest *fetchAdvancedUserProperties = [[[TWRequest alloc] 
                                              initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"] 
                                              parameters:[NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil]
                                              requestMethod:TWRequestMethodGET] autorelease];
    [fetchAdvancedUserProperties performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSError *error;
                id userInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                cell.textLabel.text = [userInfo valueForKey:@"name"];
                
            });
        }
    }];
    TWRequest *fetchUserImageRequest = [[[TWRequest alloc] 
                                        initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@", account.username]] 
                                        parameters:nil
                                         requestMethod:TWRequestMethodGET] autorelease];
    [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            UIImage *image = [UIImage imageWithData:responseData];
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.imageView.image = image;
                [cell setNeedsLayout];
            });
        }
    }];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetsListViewController *tweetsListViewController = [[[TweetsListViewController alloc] init] autorelease];
    tweetsListViewController.account = [self.accounts objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:tweetsListViewController animated:TRUE];
}

@end
