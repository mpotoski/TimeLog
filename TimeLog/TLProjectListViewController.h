//
//  TLProjectListViewController.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLClient.h"
#import "TLProject.h"

typedef void(^ProjectSelectedBlock)(TLProject *project);

@interface TLProjectListViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic) TLClient *client;
@property (nonatomic, strong) ProjectSelectedBlock completionHandler;

@end