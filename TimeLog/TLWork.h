//
//  TLWork.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TLTaskOrder.h"

@interface TLWork : PFObject<PFSubclassing>

@property (nonatomic) TLTaskOrder *taskOrder;
@property (nonatomic) CGFloat hours;
@property (nonatomic) NSDate *date;

@end