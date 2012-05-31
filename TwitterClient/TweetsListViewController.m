//
//  TweetsListViewController.m
//  TwitterClient
//
//  Created by Peter Friese on 19.09.11.
//  Copyright (c) 2011 itemis. All rights reserved.
//

#import "TweetsListViewController.h"
#import "TweetComposeViewController.h"
#import "FriendsListViewController.h"

@interface TweetsListViewController(private)
- (void)fetchData;
@end

@implementation TweetsListViewController

@synthesize account = _account;
@synthesize timeline = _timeline;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Data management

- (void)fetchData
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/home_timeline.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url 
                                                 parameters:nil 
                                              requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                self.timeline = jsonResult;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });                
            }
            else {
                NSString *message = [NSString stringWithFormat:@"Could not parse your timeline: %@", [jsonError localizedDescription]];
                [[[UIAlertView alloc] initWithTitle:@"Error" 
                                            message:message
                                           delegate:nil 
                                  cancelButtonTitle:@"Cancel" 
                                  otherButtonTitles:nil] show];
            }
        }
    }];

}

#pragma mark - Compose Tweet

- (void)composeTweet
{
    TweetComposeViewController *tweetComposeViewController = [[TweetComposeViewController alloc] init];
    tweetComposeViewController.account = self.account;
    tweetComposeViewController.tweetComposeDelegate = self;
    [self presentViewController:tweetComposeViewController animated:YES completion:nil];
    
//    TWTweetComposeViewController *tweetComposeViewController = [[TWTweetComposeViewController alloc] init];
//    [tweetComposeViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
//        [self dismissModalViewControllerAnimated:YES];
//    }];
//    [self presentModalViewController:tweetComposeViewController animated:YES];
}

- (void)tweetComposeViewController:(TweetComposeViewController *)controller didFinishWithResult:(TweetComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
    [self fetchData];
}

#pragma mark - Get Friends

- (void)getFriends
{
    FriendsListViewController *friendsListViewController = [[FriendsListViewController alloc] init];
    friendsListViewController.account = self.account;
    [self.navigationController pushViewController:friendsListViewController animated:TRUE];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
                                                                             target:self 
                                                                             action:@selector(composeTweet)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                             target:self 
                                                                             action:@selector(fetchData)];
    
    UIImage *image = [UIImage imageNamed:@"friends.png"];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithImage:image 
                                                                style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(getFriends)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:compose, refresh, friends, nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = [NSString stringWithFormat:@"@%@", self.account.username];
    [self fetchData];
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
    return [self.timeline count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    id tweet = [self.timeline objectAtIndex:[indexPath row]];
    // NSLog(@"Tweet at index %d is %@", [indexPath row], tweet);
    cell.textLabel.text = [tweet objectForKey:@"text"];
    cell.detailTextLabel.text = [tweet valueForKeyPath:@"user.name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
