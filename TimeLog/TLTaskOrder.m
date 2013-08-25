//
//  TLTaskOrder.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLTaskOrder.h"
#import <Parse/PFObject+Subclass.h>

@implementation TLTaskOrder

@dynamic name, project, client;

+ (NSString *)parseClassName
{
  return @"TaskOrder";
}

@end