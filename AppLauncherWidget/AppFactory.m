//
//  AppFactory.m
//  AppLauncherWidget
//
//  Created by Benjamin McMurrich on 25/10/2014.
//  Copyright (c) 2014 AppDelegate. All rights reserved.
//

#import "AppFactory.h"
#import "iHasApp.h"

@interface AppFactory ()

@property (nonatomic, strong) iHasApp *detectionObject;

@end

@implementation AppFactory

+ (AppFactory*)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)detectApps {
    
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) return;
    
    if(!self.detectionObject) self.detectionObject = [[iHasApp alloc] init];
    
    NSLog(@"Detection begun!");
    [self.detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
        
        NSLog(@"Incremental appDictionaries.count: %lu", (unsigned long)appDictionaries.count);
        NSMutableArray *newAppDictionaries = [NSMutableArray arrayWithArray:self.detectedApps];
        [newAppDictionaries addObjectsFromArray:appDictionaries];
        self.detectedApps = newAppDictionaries;
        self.detectedAppsSchemeDictionary = self.detectionObject.detectedAppsSchemeDictionary;
        [[NSNotificationCenter defaultCenter] postNotificationName:ALWNotificationAppsDetected object:nil];
        
    } withSuccess:^(NSArray *appDictionaries) {
        
        NSLog(@"Successful appDictionaries.count: %lu", (unsigned long)appDictionaries.count);
        self.detectedApps = appDictionaries;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:ALWNotificationAppsDetected object:nil];
        
        self.detectedAppsSchemeDictionary = self.detectionObject.detectedAppsSchemeDictionary;
        NSLog(@"self.detectedAppsSchemeDictionary: %@", self.detectedAppsSchemeDictionary);
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mcmurrich.TodayExtensionSharingDefaults"];
        [sharedDefaults setObject:(NSArray*)self.detectedAppsSchemeDictionary forKey:@"DetectedAppsSchemeDictionary"];
        [sharedDefaults synchronize];
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:ALWNotificationAppsDetected object:nil];
    }];
    
    self.detectedApps = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void) saveFavoriteApps:(NSArray*)apps {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mcmurrich.TodayExtensionSharingDefaults"];
    [sharedDefaults setObject:apps forKey:@"FavoriteApps"];
    [sharedDefaults synchronize];
}

-(NSArray*) favoriteApps {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mcmurrich.TodayExtensionSharingDefaults"];
    return [sharedDefaults objectForKey:@"FavoriteApps"];
}

@end
