//
//  TLTopLevelAddViewController.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLClient.h"
#import "TLProject.h"
#import "TLTaskOrder.h"
#import "TLWork.h"

@interface TLTopLevelAddViewController : UITableViewController

@property (nonatomic) TLWork *work;

@end
