//
//  TLClient.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLClient.h"
#import <Parse/PFObject+Subclass.h>

@implementation TLClient

@dynamic name;

+ (NSString *)parseClassName
{
  return @"Client";
}

@end