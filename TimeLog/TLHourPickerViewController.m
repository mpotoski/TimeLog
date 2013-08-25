//
//  TLHourPickerViewController.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLHourPickerViewController.h"

@interface TLHourPickerViewController ()

@property (nonatomic) UIPickerView *pickerView;

@end

@implementation TLHourPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = YES;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view addSubview:self.pickerView];
  NSInteger wholeHours = self.hours;
  NSInteger fractionHours = (self.hours - wholeHours) * 100;
  [self.pickerView selectRow:wholeHours inComponent:0 animated:YES];
  [self.pickerView selectRow:(fractionHours / 25) inComponent:1 animated:YES];
  
  self.navigationItem.title = @"Select Hours";
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
  self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillLayoutSubviews
{
  CGRect frame = self.pickerView.frame;
  frame.size.width = 150;
  self.pickerView.frame = frame;
  [self.pickerView setCenter:self.view.center];
}


#pragma mark - Picker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  if (component == 0) return 25;
  else return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  if (component == 0) {
    return [NSString stringWithFormat:@"%i", row];
  } else if (component == 1) {
    return [NSString stringWithFormat:@"%i", row * 25];
  }
  return nil;
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
  NSString *wholeHoursString = [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
  NSString *fractionHoursString = [self pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:1] forComponent:1];
  NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
  CGFloat hours = [[f numberFromString:wholeHoursString] floatValue];
  hours += [[f numberFromString:fractionHoursString] floatValue] / 100.0;
  self.completionHandler(hours);
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
