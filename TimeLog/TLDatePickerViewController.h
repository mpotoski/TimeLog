//
//  TLDatePickerViewController.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DateSelectedBlock)(NSDate *date);

@interface TLDatePickerViewController : UIViewController

@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic, strong) DateSelectedBlock completionHandler;

@end