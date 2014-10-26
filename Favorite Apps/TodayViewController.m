//
//  TodayViewController.m
//  Favorite Apps
//
//  Created by Mac Dev Test on 17/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "UIKit+AFNetworking.h"

@interface TodayViewController () <NCWidgetProviding>

@property NSArray * apps;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.preferredContentSize = CGSizeMake(320, 64);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    [self refreshDisplay];
    completionHandler(NCUpdateResultNewData);
}

-(void) refreshDisplay {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mcmurrich.TodayExtensionSharingDefaults"];
    self.apps = [sharedDefaults objectForKey:@"FavoriteApps"];
    
    for (int i=1; i<=5; i++) {
        
        UIButton * button = (UIButton*) [self.view viewWithTag:i];
        
        button.layer.cornerRadius = 10;
        button.clipsToBounds = TRUE;
        
        if(i <= self.apps.count) {
            
            button.hidden = FALSE;
            [button setTitle:@"" forState:UIControlStateNormal];
            
            NSDictionary * appDictionary = self.apps[i-1];
            
            NSString *iconUrlString = [appDictionary objectForKey:@"artworkUrl512"];
            NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
            NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
            [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
            iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];
            [button setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:iconUrlString]];
            
        } else {
            if (i==self.apps.count+1) {
                button.hidden = FALSE;
                [button setTitle:@"+" forState:UIControlStateNormal];
            } else {
                button.hidden = TRUE;
            }
        }
    }
}

- (IBAction) goToApp: (id)sender {
    UIButton * button = (UIButton*)sender;
    
    if(button.tag > self.apps.count) {
        NSURL *url = [NSURL URLWithString:@"AppLauncherWidget://add"];
        [self.extensionContext openURL:url completionHandler:nil];
    } else {
        NSDictionary * app = self.apps[button.tag-1];
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mcmurrich.TodayExtensionSharingDefaults"];
        NSDictionary * detectedAppsSchemeDictionary = [sharedDefaults objectForKey:@"DetectedAppsSchemeDictionary"];
        
        NSURL *url = [NSURL URLWithString:detectedAppsSchemeDictionary[[app[@"trackId"] description]]];
        [self.extensionContext openURL:url completionHandler:nil];
    }
}

@end
