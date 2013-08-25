//
//  TLWork.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLWork.h"
#import <Parse/PFObject+Subclass.h>

@implementation TLWork

@dynamic taskOrder, hours, date;

+ (NSString *)parseClassName
{
  return @"Work";
}

@end