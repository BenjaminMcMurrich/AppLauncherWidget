//
//  InstalledAppsTableViewController.m
//  AppLauncherWidget
//
//  Created by Mac Dev Test on 17/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import "DetectedAppsTableViewController.h"
#import "AppFactory.h"
#import "UIImageView+AFNetworking.h"

@interface DetectedAppsTableViewController ()

@property (nonatomic, strong) NSArray *detectedApps;

@property id completionBlock;

@end

@implementation DetectedAppsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detectedApps = [AppFactory sharedInstance].detectedApps;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ALWNotificationAppsDetected object:nil queue:0 usingBlock:^(NSNotification *note) {
        self.detectedApps = [AppFactory sharedInstance].detectedApps;
        [self.tableView reloadData];
    }];
}

- (void) completionHandler:(void (^)(NSDictionary * app))block {
    self.completionBlock = block;
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
    if(self.detectedApps.count ==0) return @"Apps detection in progress...";
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.completionBlock) ((void (^)()) self.completionBlock)(self.detectedApps[indexPath.row]);
    }];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
