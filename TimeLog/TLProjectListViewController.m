//
//  TLProjectListViewController.m
//  TimeLog
//
//  Created by Megan Potoski on 2013-08-24.
//  Copyright (c) 2013 Megan Potoski. All rights reserved.
//

#import "TLProjectListViewController.h"

@interface TLProjectListViewController ()

// List of projects
@property (nonatomic, strong) NSMutableArray *projects;

// For searching
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *filteredArray;

// For editing
@property (nonatomic) int indexToDelete;
@property (nonatomic) UITableView *tableToDelete;

@end

@implementation TLProjectListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    self.projects = [[NSMutableArray alloc] init];
    self.filteredArray = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.title = [NSString stringWithFormat:@"%@ - Projects", self.client.name];
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  [self addSearchBar];
  [self reloadProjects];
}

- (void)reloadProjects
{
  PFQuery *query = [TLProject query];
  [query whereKey:kTLProjectClientKey equalTo:self.client];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (objects) {
      self.projects = [objects mutableCopy];
      [self.projects sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((TLProject *)obj1).name compare:((TLProject *)obj2).name];
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
    return [self.projects count];
  } else if (tableView == self.searchController.searchResultsTableView) {
    return [self.filteredArray count];
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProjectCell"];
  }
  
  // Fill with project info
  TLProject *project = [self projectForIndexPath:indexPath inTableView:tableView];
  cell.textLabel.text = project.name;
  return cell;
}

- (TLProject *)projectForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
  if (tableView == self.tableView) {
    return [self.projects objectAtIndex:indexPath.row];
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
  TLProject *project = [self projectForIndexPath:indexPath inTableView:tableView];
  if (self.completionHandler) self.completionHandler(project);
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This will delete all related task orders, and work logs."
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
  self.filteredArray = [[self.projects filteredArrayUsingPredicate:predicate] mutableCopy];
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addProject:(id)sender
{
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Project"
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
    TLProject *newProject = [TLProject object];
    newProject.name = nameField.text;
    newProject.client = self.client;
    [newProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      [self reloadProjects];
    }];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
    
    // Find the correct project to delete
    TLProject *projectToDelete = [self projectForIndexPath:[NSIndexPath indexPathForRow:self.indexToDelete inSection:0] inTableView:self.tableToDelete];
    
    // Remove project, delete from db, and delete all related bills
    [self.projects removeObject:projectToDelete];
    [self.filteredArray removeObject:projectToDelete];
    /*PFQuery *billsQuery = [BLBill query];
     [billsQuery whereKey:kBLBillProjectKey equalTo:projectToDelete];
     [billsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (objects) {
     for (BLBill *billToDelete in objects) {
     [billToDelete deleteInBackground];
     }
     }
     }];*/
    [projectToDelete deleteInBackground];
    [self.tableToDelete deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.indexToDelete inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
  }
}

@end

