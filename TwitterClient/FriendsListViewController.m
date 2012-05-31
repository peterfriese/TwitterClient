//
//  FriendsListViewController.m
//  TwitterClient
//
//  Created by Julien Chaumond on 30/05/12.
//  Copyright (c) 2012 itemis. All rights reserved.
//

#import "FriendsListViewController.h"

@interface FriendsListViewController()
- (void)fetchData;
- (void)fetchFriendsInfo;
@property (strong, nonatomic) NSCache *imageCache;
@end

@implementation FriendsListViewController

@synthesize account = _account;
@synthesize friends = _friends;
@synthesize friendIds = _friendIds;

@synthesize imageCache = _imageCache;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _imageCache = [[NSCache alloc] init];
        [_imageCache setName:@"TWImageCache"];
        
        _friends = [[NSMutableArray alloc] init];
        
        [self fetchData];
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [_imageCache removeAllObjects];
    [super didReceiveMemoryWarning];
}


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
    self.title = @"Friends";
    [self fetchData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Data management

- (void)fetchData
{
    // We have to first get user ids, then only request user info.
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/friends/ids.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url 
                                             parameters:nil 
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
            if (jsonResult != nil) {
                
                
                self.friendIds = [jsonResult objectForKey:@"ids"];
                
                // Not sure whether I can just call the function directly here...
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self fetchFriendsInfo];
                });                
            }
            else {
                NSString *message = [NSString stringWithFormat:@"Could not parse your friends list: %@", [jsonError localizedDescription]];
                [[[UIAlertView alloc] initWithTitle:@"Error" 
                                            message:message
                                           delegate:nil 
                                  cancelButtonTitle:@"Cancel" 
                                  otherButtonTitles:nil] show];
            }
        }
    }];
    
}


- (void)fetchFriendsInfo
{
    // Twitter only allows getting info for up to a fixed number of user_ids at once (supposedly 100),
    // so we'll have to break the ids array into smaller pieces and make multiple TWRequests.
    
    static const int kItemsPerView = 50;
    int numViews = (int) ceil((float) [self.friendIds count] / kItemsPerView);
    
    // NSLog(@"%d", [self.friendIds count]);
    // NSLog(@"%d", numViews);
    
    for (int viewIndex = 0; viewIndex < numViews; viewIndex++) {
        
        int numItems;
        
        if (viewIndex * kItemsPerView + kItemsPerView - 1 <= [self.friendIds count]) {
            numItems = kItemsPerView;
        }
        else {
            numItems = [self.friendIds count] - viewIndex * kItemsPerView;
        }
        
        // There must be a more straightforward way of slicing self.friendIds into subarrays of length at most kItemsPerView...
        
        NSRange rangeForView = NSMakeRange(viewIndex * kItemsPerView, numItems);
        NSArray *itemsForView = [self.friendIds subarrayWithRange:rangeForView];
        
        NSString *userIds = [itemsForView componentsJoinedByString:@","];
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/users/lookup.json"];
        TWRequest *request = [[TWRequest alloc] initWithURL:url 
                                                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:userIds, @"user_id", nil] 
                                              requestMethod:TWRequestMethodPOST];
        [request setAccount:self.account];
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) {
                NSError *jsonError = nil;
                id jsonResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                if (jsonResult != nil) {
                    
                    // Append to self.friends (which must be mutable):
                    
                    [self.friends addObjectsFromArray:jsonResult];
                    
                    // Every time we receive new friends info, reload the table view:
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });                
                }
                else {
                    NSString *message = [NSString stringWithFormat:@"Could not parse your friends info: %@", [jsonError localizedDescription]];
                    [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                message:message
                                               delegate:nil 
                                      cancelButtonTitle:@"Cancel" 
                                      otherButtonTitles:nil] show];
                }
            }
        }];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    id friend = [self.friends objectAtIndex:[indexPath row]];
    // NSLog(@"Friend at index %d is %@", [indexPath row], friend);
    cell.textLabel.text = [friend objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", [friend objectForKey:@"screen_name"]];
    
    
    
    UIImage *image = [_imageCache objectForKey:[friend objectForKey:@"screen_name"]];
    if (image) {
        cell.imageView.image = image;        
    }
    else {
        // We could use the profile_image that's referenced inside users.lookup, which would save us another API request,
        // but this would be the normal version (not the larger one).
        
        TWRequest *fetchUserImageRequest = [[TWRequest alloc] 
                                            initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@", [friend objectForKey:@"screen_name"]]] 
                                            parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"bigger", @"size", nil]
                                            requestMethod:TWRequestMethodGET];
        [fetchUserImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) {
                UIImage *image = [UIImage imageWithData:responseData];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [_imageCache setObject:image forKey:[friend objectForKey:@"screen_name"]];                    
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
                });
            }
        }]; 
    }
    
    // This has been tested up to about 1000 friends. It could very well break if you've got thousands of friends on Twitter.
    
    // @todo Look into SDWebImage (https://github.com/rs/SDWebImage) to improve image performance.
    
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
