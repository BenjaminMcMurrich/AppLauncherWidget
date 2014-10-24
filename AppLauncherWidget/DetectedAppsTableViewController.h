//
//  InstalledAppsTableViewController.h
//  AppLauncherWidget
//
//  Created by Mac Dev Test on 17/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetectedAppsTableViewController : UITableViewController

- (IBAction)cancelButtonAction:(id)sender;

- (void) completionHandler:(void (^)(NSDictionary * app))block;

@end
