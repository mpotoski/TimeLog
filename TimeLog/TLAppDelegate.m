//
//  TLAppDelegate.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLAppDelegate.h"
#import <Parse/Parse.h>
#import "TLClient.h"
#import "TLProject.h"
#import "TLTaskOrder.h"
#import "TLWork.h"
#import "TLClientListViewController.h"
#import "TLTopLevelAddViewController.h"

@implementation TLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Add Parse credentials
  [TLClient registerSubclass];
  [TLProject registerSubclass];
  [TLTaskOrder registerSubclass];
  [TLWork registerSubclass];
  [Parse setApplicationId:@"xPXl1vLNIwd1hqGNVKfYjS8YEagnJuFAbkSLYl9s"
                clientKey:@"9Ms0PoUiugeNynJls4xoOThz2ZHTUlqdiZBKhkGQ"];
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
  
  // Set up main tab bar controller
  TLClientListViewController *clientList = [[TLClientListViewController alloc] initWithStyle:UITableViewStylePlain];
  UINavigationController *clientNav = [[UINavigationController alloc] initWithRootViewController:clientList];
  TLTopLevelAddViewController *addController = [[TLTopLevelAddViewController alloc] initWithStyle:UITableViewStyleGrouped];
  UINavigationController *addNav = [[UINavigationController alloc] initWithRootViewController:addController];
  UITabBarController *mainController = [[UITabBarController alloc] init];
  mainController.viewControllers = @[addNav];
  [[mainController.tabBar.items objectAtIndex:0] setTitle:@"Add"];
  
  // Set up app window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = mainController;
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

@end