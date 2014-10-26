//
//  AppFactory.h
//  AppLauncherWidget
//
//  Created by Benjamin McMurrich on 25/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const ALWNotificationAppsDetected = @"fr.mcmurrich.AppLauncherWidget.appsDetected";

@interface AppFactory : NSObject

+ (AppFactory*)sharedInstance;

@property (nonatomic, strong) NSArray * detectedApps;
@property (nonatomic, strong) NSDictionary *detectedAppsSchemeDictionary;

- (void)detectApps;

-(void) saveFavoriteApps:(NSArray*)apps;
-(NSArray*) favoriteApps;

@end
