//
//  TLProject.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLProject.h"
#import <Parse/PFObject+Subclass.h>

@implementation TLProject

@dynamic name, client;

+ (NSString *)parseClassName
{
  return @"Project";
}

@end
