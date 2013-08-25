//
//  TLTopLevelAddViewController.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLTopLevelAddViewController.h"
#import "TLClientListViewController.h"
#import "TLProjectListViewController.h"
#import "TLTaskOrderListViewController.h"
#import "TLDatePickerViewController.h"
#import "TLHourPickerViewController.h"

@interface TLTopLevelAddViewController ()

// Client level
@property (nonatomic) TLClient *client;
@property (nonatomic) NSDate *date;
@property (nonatomic) CGFloat hours;

// Project level
@property (nonatomic) NSMutableArray *projects;
@property (nonatomic) NSMutableArray *projectTotals;

// Task order level
@property (nonatomic) NSMutableArray *taskOrdersArray;
@property (nonatomic) NSMutableArray *taskOrderTotals;

@end

@implementation TLTopLevelAddViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.date = [NSDate date];
  self.projects = [[NSMutableArray alloc] init];
  self.projectTotals = [[NSMutableArray alloc] init];
  self.taskOrdersArray = [[NSMutableArray alloc] init];
  self.taskOrderTotals = [[NSMutableArray alloc] init];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:nil];
  self.navigationItem.rightBarButtonItem = doneButton;
  self.navigationItem.title = @"Add Work";
}


#pragma mark - Override setter

- (void)setClient:(TLClient *)client
{
  _client = client;
  [self.tableView reloadData];
}

- (void)setDate:(NSDate *)date
{
  _date = date;
  [self.tableView reloadData];
}

- (void)setHours:(CGFloat)hours
{
  _hours = hours;
  [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (self.client == nil) {
    return 1;
  } else {
    return 2 + [self.projects count];
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"Total";
  } else if (section == 1) {
    return @"Projects";
  } else {
    return ((TLProject *)[self.projects objectAtIndex:section - 2]).name;
  }
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 3;
  }
  else if (section == 1) {
    return [self.projects count] + 1;
  }
  else {
    return [[self taskOrdersForSection:section] count] + 1;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  // Client total section
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Client";
      if (self.client) {
        cell.detailTextLabel.text = self.client.name;
      } else {
        cell.detailTextLabel.text = nil;
      }
    } else if (indexPath.row == 1) {
      cell.textLabel.text = @"Date";
      NSDateFormatter *f = [[NSDateFormatter alloc] init];
      [f setDateFormat:@"EEEE"];
      NSString *weekday = [f stringFromDate:self.date];
      [f setDateStyle:NSDateFormatterLongStyle];
      NSString *day = [f stringFromDate:self.date];
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", weekday, day];
    } else if (indexPath.row == 2) {
      cell.textLabel.text = @"Hours";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f", self.hours];
    }
  }
  
  // Project section
  else if (indexPath.section == 1) {
    if (indexPath.row == [self.projects count]) {
      cell.textLabel.text = @"Add Project";
      cell.detailTextLabel.text = nil;
    } else {
      TLProject *project = [self.projects objectAtIndex:indexPath.row];
      CGFloat projectTotal = [[self.projectTotals objectAtIndex:indexPath.row] floatValue];
      cell.textLabel.text = project.name;
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f", projectTotal];
    }
  }
  
  // Task orders section
  else {
    NSMutableArray *taskOrders = [self taskOrdersForSection:indexPath.section];
    NSMutableArray *taskOrderHours = [self taskOrderHoursForSection:indexPath.section];
    if (indexPath.row == [taskOrders count]) {
      cell.textLabel.text = @"Add Task Order";
      cell.detailTextLabel.text = nil;
    } else {
      TLTaskOrder *taskOrder = [taskOrders objectAtIndex:indexPath.row];
      CGFloat taskOrderAmount = [[taskOrderHours objectAtIndex:indexPath.row] floatValue];
      cell.textLabel.text = taskOrder.name;
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f", taskOrderAmount];
    }
  }
  
  return cell;
}

- (NSMutableArray *)taskOrdersForSection:(NSInteger)section
{
  return [self.taskOrdersArray objectAtIndex:section - 2];
}

- (NSMutableArray *)taskOrderHoursForSection:(NSInteger)section
{
  return [self.taskOrderTotals objectAtIndex:section - 2];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  // Client total section
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      [self selectClient];
    } else if (indexPath.row == 1) {
      [self selectDate];
    } else if (indexPath.row == 2) {
      [self selectHours:indexPath];
    }
  }
  
  // Projects section
  else if (indexPath.section == 1) {
    if (indexPath.row == [self.projects count]) {
      [self addProject];
    } else {
      [self selectHours:indexPath];
    }
  }
  
  // Task orders section
  else {
    NSMutableArray *taskOrders = [self taskOrdersForSection:indexPath.section];
    if (indexPath.row == [taskOrders count]) {
      [self addTaskOrder:indexPath.section - 2];
    } else {
      [self selectHours:indexPath];
    }
  }
}


#pragma mark - Editing fields

- (void)selectClient
{
  TLClientListViewController *clientList = [[TLClientListViewController alloc] init];
  clientList.selectedClient = self.client;
  clientList.completionHandler = ^(TLClient *client) {
    self.client = client;
  };
  UINavigationController *clientNav = [[UINavigationController alloc] initWithRootViewController:clientList];
  clientNav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:clientNav animated:YES completion:nil];
}

- (void)selectDate
{
  TLDatePickerViewController *dateController = [[TLDatePickerViewController alloc] init];
  dateController.datePicker.date = self.date;
  dateController.completionHandler = ^(NSDate *date) {
    self.date = date;
  };
  UINavigationController *dateNav = [[UINavigationController alloc] initWithRootViewController:dateController];
  dateNav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:dateNav animated:YES completion:nil];
}

- (void)selectHours:(NSIndexPath *)indexPath
{
  TLHourPickerViewController *hoursController = [[TLHourPickerViewController alloc] init];
  if (indexPath.section == 0) {
    hoursController.hours = self.hours;
  } else if (indexPath.section == 1) {
    hoursController.hours = [[self.projectTotals objectAtIndex:indexPath.row] floatValue];
  }
  hoursController.completionHandler = ^(CGFloat hours) {
    if (indexPath.section == 0) {
      self.hours = hours;
    } else if (indexPath.section == 1) {
      [self.projectTotals setObject:@(hours) atIndexedSubscript:indexPath.row];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
      NSMutableArray *taskOrderHours = [self taskOrderHoursForSection:indexPath.section];
      [taskOrderHours setObject:@(hours) atIndexedSubscript:indexPath.row];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  };
  UINavigationController *hoursNav = [[UINavigationController alloc] initWithRootViewController:hoursController];
  hoursNav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:hoursNav animated:YES completion:nil];
}

- (void)addProject
{
  TLProjectListViewController *projectList = [[TLProjectListViewController alloc] init];
  projectList.client = self.client;
  projectList.completionHandler = ^(TLProject *project) {
    if ([[self.projects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name like %@", project.name]] count] > 0) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Duplicate Project"
                                                   message:@"You've already added this one."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
      [av show];
    } else {
      [self.projects addObject:project];
      [self.projectTotals addObject:@(0.0)];
      [self.taskOrdersArray addObject:[[NSMutableArray alloc] init]];
      [self.taskOrderTotals addObject:[[NSMutableArray alloc] init]];
      [self.tableView reloadData];
    }
  };
  UINavigationController *projectNav = [[UINavigationController alloc] initWithRootViewController:projectList];
  projectNav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:projectNav animated:YES completion:nil];
}

- (void)addTaskOrder:(NSInteger)projectIndex
{
  TLTaskOrderListViewController *taskOrderList = [[TLTaskOrderListViewController alloc] init];
  taskOrderList.project = [self.projects objectAtIndex:projectIndex];
  taskOrderList.completionHandler = ^(TLTaskOrder *taskOrder) {
    NSMutableArray *taskOrders = [self.taskOrdersArray objectAtIndex:projectIndex];
    if ([[taskOrders filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name like %@", taskOrder.name]] count] > 0) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Duplicate Task Order"
                                                   message:@"You've already added this one."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
      [av show];
    } else {
      NSMutableArray *taskOrders = [self.taskOrdersArray objectAtIndex:projectIndex];
      [taskOrders addObject:taskOrder];
      NSMutableArray *taskOrderHours = [self.taskOrderTotals objectAtIndex:projectIndex];
      [taskOrderHours addObject:@(0.0)];
      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:projectIndex + 2] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  };
  UINavigationController *taskOrderNav = [[UINavigationController alloc] initWithRootViewController:taskOrderList];
  taskOrderNav.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:taskOrderNav animated:YES completion:nil];
}

@end
