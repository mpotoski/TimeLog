//
//  TLHourPickerViewController.h
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HoursSelectedBlock)(CGFloat hours);

@interface TLHourPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) CGFloat hours;
@property (nonatomic, strong) HoursSelectedBlock completionHandler;

@end
