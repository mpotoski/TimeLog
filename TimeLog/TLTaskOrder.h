//
//  TLTaskOrder.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TLProject.h"
#import "TLClient.h"

#define kTLTaskOrderClientKey @"client"
#define kTLTaskOrderProjectKey @"project"

@interface TLTaskOrder : PFObject<PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) TLProject *project;
@property (nonatomic) TLClient *client;

@end
