//
//  TLClientListViewController.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLClientListViewController.h"
#import "TLProjectListViewController.h"

@interface TLClientListViewController ()

// List of clients
@property (nonatomic, strong) NSMutableArray *clients;

// For searching
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *filteredArray;

// For editing
@property (nonatomic) int indexToDelete;
@property (nonatomic) UITableView *tableToDelete;

@end

@implementation TLClientListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    self.clients = [[NSMutableArray alloc] init];
    self.filteredArray = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.title = @"Select Client";
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClient:)];
  self.navigationItem.rightBarButtonItem = addButton;
  [self addSearchBar];
  [self reloadClients];
}

- (void)reloadClients
{
  PFQuery *query = [TLClient query];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (objects) {
      self.clients = [objects mutableCopy];
      [self.clients sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((TLClient *)obj1).name compare:((TLClient *)obj2).name];
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
    return [self.clients count];
  } else if (tableView == self.searchController.searchResultsTableView) {
    return [self.filteredArray count];
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClientCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClientCell"];
  }

  // Fill with client info
  TLClient *client = [self clientForIndexPath:indexPath inTableView:tableView];
  cell.textLabel.text = client.name;
  if ([client.name isEqual:self.selectedClient.name]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

- (TLClient *)clientForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
  if (tableView == self.tableView) {
    return [self.clients objectAtIndex:indexPath.row];
  } else if (tableView == self.searchController.searchResultsTableView) {
    return [self.filteredArray objectAtIndex:indexPath.row];
  }
  return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Get selected client
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  TLClient *client = [self clientForIndexPath:indexPath inTableView:tableView];
  if (self.completionHandler) self.completionHandler(client);
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  
  // Go to project list
  // TLProjectListViewController *projectList = [[TLProjectListViewController alloc] init];
  // projectList.client = client;
  // [self.navigationController pushViewController:projectList animated:YES];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This will delete all related projects, task orders, and work logs."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    // [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet showInView:self.view];
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
  self.filteredArray = [[self.clients filteredArrayUsingPredicate:predicate] mutableCopy];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addClient:(id)sender
{
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Client"
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
    TLClient *newClient = [TLClient object];
    newClient.name = nameField.text;
    [newClient saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      [self reloadClients];
    }];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
    
    // Find the correct project to delete
    TLClient *clientToDelete = [self clientForIndexPath:[NSIndexPath indexPathForRow:self.indexToDelete inSection:0] inTableView:self.tableToDelete];
    
    // Remove project, delete from db, and delete all related bills
    [self.clients removeObject:clientToDelete];
    [self.filteredArray removeObject:clientToDelete];
    /*PFQuery *billsQuery = [BLBill query];
    [billsQuery whereKey:kBLBillProjectKey equalTo:projectToDelete];
    [billsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      if (objects) {
        for (BLBill *billToDelete in objects) {
          [billToDelete deleteInBackground];
        }
      }
    }];*/
    [clientToDelete deleteInBackground];
    [self.tableToDelete deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.indexToDelete inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
  }
}

@end

