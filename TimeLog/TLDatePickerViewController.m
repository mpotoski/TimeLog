//
//  TLDatePickerViewController.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLDatePickerViewController.h"

@interface TLDatePickerViewController ()

@end

@implementation TLDatePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view addSubview:self.datePicker];
  self.navigationItem.title = @"Select Date";
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
  self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillLayoutSubviews
{
  [self.datePicker setCenter:self.view.center];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
  self.completionHandler(self.datePicker.date);
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
