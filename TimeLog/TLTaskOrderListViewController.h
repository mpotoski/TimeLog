//
//  TLTaskOrderListViewController.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLClient.h"
#import "TLProject.h"
#import "TLTaskOrder.h"

typedef void(^TaskOrderSelectedBlock)(TLTaskOrder *taskOrder);

@interface TLTaskOrderListViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic) TLProject *project;
@property (nonatomic, strong) TaskOrderSelectedBlock completionHandler;

@end