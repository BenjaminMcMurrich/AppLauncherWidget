//
//  FavoriteAppsTableViewController.m
//  AppLauncherWidget
//
//  Created by Benjamin McMurrich on 23/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import "FavoriteAppsTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AppFactory.h"
#import "DetectedAppsTableViewController.h"

@interface FavoriteAppsTableViewController ()

@property (nonatomic, strong) NSMutableArray * favoriteApps;

@end

@implementation FavoriteAppsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.favoriteApps = [[NSMutableArray alloc] initWithArray:[[AppFactory sharedInstance] favoriteApps]];
    if(self.favoriteApps.count > 0) {
        UIBarButtonItem * edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
        [self.navigationItem setLeftBarButtonItem:edit];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"fr.mcmurrich.AppLauncherWidget.addApp" object:nil queue:0 usingBlock:^(NSNotification *note) {
        [self addButtonAction:nil];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.favoriteApps.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Favorite apps";
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(self.favoriteApps.count == 0) return @"Tap the + button to add your first favorite app.";
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteAppCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary * appDictionary = self.favoriteApps[indexPath.row];
    
    NSString *trackName = [appDictionary objectForKey:@"trackName"];
    //NSString *artworkUrl60 = [appDictionary objectForKey:@"artworkUrl60"];
    
    NSString *iconUrlString = [appDictionary objectForKey:@"artworkUrl512"];
    NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
    NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
    [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
    iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];
    
    UILabel * appNameLabel = (UILabel *) [cell viewWithTag:2];
    appNameLabel.text = trackName;
    
    UIImageView * appIconImageview = (UIImageView *) [cell viewWithTag:1];
    [appIconImageview setImageWithURL:[NSURL URLWithString:iconUrlString]];
    appIconImageview.layer.cornerRadius = 10;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.favoriteApps removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        if (self.favoriteApps.count == 0)[self.navigationItem setLeftBarButtonItem:nil];
        [[AppFactory sharedInstance] saveFavoriteApps:self.favoriteApps];
        
        UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
        [self.navigationItem setRightBarButtonItem:add];
        
        if(self.favoriteApps.count == 0) [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSDictionary *appToMove = [self.favoriteApps objectAtIndex:sourceIndexPath.row];
    [self.favoriteApps removeObjectAtIndex:sourceIndexPath.row];
    [self.favoriteApps insertObject:appToMove atIndex:destinationIndexPath.row];
    [[AppFactory sharedInstance] saveFavoriteApps:self.favoriteApps];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (IBAction)editButtonAction:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:FALSE animated:YES];
        UIBarButtonItem * edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
        [self.navigationItem setLeftBarButtonItem:edit];
    } else {
        [self.tableView setEditing:TRUE animated:YES];
        UIBarButtonItem * done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonAction:)];
        [self.navigationItem setLeftBarButtonItem:done];
    }
}

- (IBAction)addButtonAction:(id)sender {

    if (self.tableView.editing && self.favoriteApps.count>0) {
        [self.tableView setEditing:FALSE animated:YES];
        UIBarButtonItem * edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
        [self.navigationItem setLeftBarButtonItem:edit];
    }
    
    DetectedAppsTableViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetectedAppsTableViewController"];
    
    [viewController completionHandler:^(NSDictionary *app) {
        // Tell the tableView we're going to add (or remove) items.
        
        if(self.favoriteApps.count == 0) [self.tableView reloadData];
        
        [self.tableView beginUpdates];
        
        [self.favoriteApps addObject:app];
        
        // Tell the tableView about the item that was added.
        NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:(self.favoriteApps.count - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // Tell the tableView we have finished adding or removing items.
        [self.tableView endUpdates];
        
        // Scroll the tableView so the new item is visible
        [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
        
        if (self.favoriteApps.count >= 5)[self.navigationItem setRightBarButtonItem:nil];
        
        UIBarButtonItem * edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction:)];
        [self.navigationItem setLeftBarButtonItem:edit];
        
        [[AppFactory sharedInstance] saveFavoriteApps:self.favoriteApps];
    }];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
@end
