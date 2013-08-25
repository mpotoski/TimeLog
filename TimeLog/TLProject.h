//
//  TLProject.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TLClient.h"

#define kTLProjectClientKey @"client"

@interface TLProject : PFObject<PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) TLClient *client;

@end