//
//  InstalledAppsTableViewController.m
//  AppLauncherWidget
//
//  Created by Mac Dev Test on 17/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import "InstalledAppsTableViewController.h"
#import "iHasApp.h"
#import "UIImageView+AFNetworking.h"

@interface InstalledAppsTableViewController ()

@property (nonatomic, strong) iHasApp *detectionObject;
@property (nonatomic, strong) NSArray *detectedApps;

@end

@implementation InstalledAppsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detectionObject = [[iHasApp alloc] init];
    
    [self detectApps];
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
    return self.detectedApps.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Detected apps";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetectedAppCell" forIndexPath:indexPath];
    
    NSDictionary *appDictionary = [self.detectedApps objectAtIndex:indexPath.row];
    
    NSString *trackName = [appDictionary objectForKey:@"trackName"];
    NSString *trackId = [[appDictionary objectForKey:@"trackId"] description];
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - iHasApp methods

- (void)detectApps
{
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) return;
    
    NSLog(@"Detection begun!");
    [self.detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
        NSLog(@"Incremental appDictionaries.count: %lu", (unsigned long)appDictionaries.count);
        NSMutableArray *newAppDictionaries = [NSMutableArray arrayWithArray:self.detectedApps];
        [newAppDictionaries addObjectsFromArray:appDictionaries];
        self.detectedApps = newAppDictionaries;
        [self.tableView reloadData];
    } withSuccess:^(NSArray *appDictionaries) {
        NSLog(@"Successful appDictionaries.count: %lu", (unsigned long)appDictionaries.count);
        self.detectedApps = appDictionaries;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.tableView reloadData];
    } withFailure:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        self.detectedApps = [NSArray array];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [self.tableView reloadData];
    }];
    
    self.detectedApps = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.tableView reloadData];
}

@end
