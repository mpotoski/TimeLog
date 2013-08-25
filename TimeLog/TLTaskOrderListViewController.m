//
//  TLTaskOrderListViewController.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLTaskOrderListViewController.h"

@interface TLTaskOrderListViewController ()

// List of task orders
@property (nonatomic, strong) NSMutableArray *taskOrders;

// For searching
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *filteredArray;

// For editing
@property (nonatomic) int indexToDelete;
@property (nonatomic) UITableView *tableToDelete;

@end

@implementation TLTaskOrderListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    self.taskOrders = [[NSMutableArray alloc] init];
    self.filteredArray = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.title = [NSString stringWithFormat:@"%@ - Task Orders", self.project.name];
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskOrder:)];
  self.navigationItem.rightBarButtonItem = addButton;
  [self addSearchBar];
  [self reloadTaskOrders];
}

- (void)reloadTaskOrders
{
  PFQuery *query = [TLTaskOrder query];
  [query whereKey:kTLTaskOrderProjectKey equalTo:self.project];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (objects) {
      self.taskOrders = [objects mutableCopy];
      [self.taskOrders sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((TLTaskOrder *)obj1).name compare:((TLTaskOrder *)obj2).name];
      }];
      [self.tableView reloadData];
    }
  }];
}

- (void)addSearchBar
{
  // Add search bar
  self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.tableView.rowHeight)];
  self.tableView.tableHeaderView = self.searchBar;
  self.searchBar.delegate = self;
  
  // Create search display controller
  self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
  self.searchController.searchResultsDataSource = self;
  self.searchController.searchResultsDelegate = self;
  self.searchController.delegate = self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView == self.tableView) {
    return [self.taskOrders count];
  } else if (tableView == self.searchController.searchResultsTableView) {
    return [self.filteredArray count];
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskOrderCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskOrderCell"];
  }
  
  // Fill with project info
  TLTaskOrder *taskOrder = [self taskOrderForIndexPath:indexPath inTableView:tableView];
  cell.textLabel.text = taskOrder.name;
  return cell;
}

- (TLTaskOrder *)taskOrderForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
  if (tableView == self.tableView) {
    return [self.taskOrders objectAtIndex:indexPath.row];
  } else if (tableView == self.searchController.searchResultsTableView) {
    return [self.filteredArray objectAtIndex:indexPath.row];
  }
  return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Get selected project
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  TLTaskOrder *taskOrder = [self taskOrderForIndexPath:indexPath inTableView:tableView];
  if (self.completionHandler) self.completionHandler(taskOrder);
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    self.indexToDelete = indexPath.row;
    self.tableToDelete = tableView;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This will delete all related work logs."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
}


#pragma mark - Search delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
  [self filterForSearch:searchString];
  return YES;
}

- (void)filterForSearch:(NSString *)searchString
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", searchString];
  self.filteredArray = [[self.taskOrders filteredArrayUsingPredicate:predicate] mutableCopy];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addTaskOrder:(id)sender
{
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Task Order"
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     otherButtonTitles:@"Add", nil];
  av.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField *nameField = [av textFieldAtIndex:0];
  nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
  [av show];
}


#pragma mark - Alert view/action sheet delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    UITextField *nameField = [alertView textFieldAtIndex:0];
    if (nameField.text == nil || [nameField.text length] == 0) {
      UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Name"
                                                   message:@"Name cannot be blank."
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
      [av show];
    }
    TLTaskOrder *taskOrder = [TLTaskOrder object];
    taskOrder.name = nameField.text;
    taskOrder.project = self.project;
    [taskOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      [self reloadTaskOrders];
    }];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
    
    // Find the correct task order to delete
    TLTaskOrder *taskOrderToDelete = [self taskOrderForIndexPath:[NSIndexPath indexPathForRow:self.indexToDelete inSection:0] inTableView:self.tableToDelete];
    
    // Remove task order
    [self.taskOrders removeObject:taskOrderToDelete];
    [self.filteredArray removeObject:taskOrderToDelete];
    /*PFQuery *billsQuery = [BLBill query];
     [billsQuery whereKey:kBLBillProjectKey equalTo:projectToDelete];
     [billsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (objects) {
     for (BLBill *billToDelete in objects) {
     [billToDelete deleteInBackground];
     }
     }
     }];*/
    [taskOrderToDelete deleteInBackground];
    [self.tableToDelete deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.indexToDelete inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
  }
}

@end

