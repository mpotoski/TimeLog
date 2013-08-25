//
//  TLClientListViewController.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLClient.h"

typedef void(^ClientSelectedBlock)(TLClient *client);

@interface TLClientListViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) ClientSelectedBlock completionHandler;
@property (nonatomic) TLClient *selectedClient;

@end