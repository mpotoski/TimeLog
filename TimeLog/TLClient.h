//
//  TLClient.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TLClient : PFObject<PFSubclassing>

@property (nonatomic) NSString *name;

@end