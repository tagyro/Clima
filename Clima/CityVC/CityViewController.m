//
//  CityViewController.m
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import "CityViewController.h"

#import "GeoNames.h"

#import <tolo/Tolo.h>

#import <AMLocalized/LocalizationSystem.h>

#import "Common.h"

@interface CityViewController () {
    
    UISearchController *searchController;
    
    NSArray *filteredCities;
    
    GeoNames *geoNames;
}

@end

@implementation CityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    geoNames = [[GeoNames alloc] initWithUsername:kGeoNameUsername];
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.delegate = self;
    searchController.searchBar.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO; // we want to be able to select a result
    searchController.extendedLayoutIncludesOpaqueBars = NO;
    
    self.tableView.tableHeaderView = searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    // https://openradar.appspot.com/17315501
    [searchController.searchBar sizeToFit];
    
    REGISTER();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [searchController setActive:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filteredCities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"kCityCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    GNMLocation *location = [filteredCities objectAtIndex:indexPath.row];
    
    cell.textLabel.text = location.toponymName;
    cell.detailTextLabel.text = location.countryName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GNESelectPlace *event = [GNESelectPlace new];
    event.location = [filteredCities objectAtIndex:indexPath.row];
    
    PUBLISH(event);
    
    [self exit];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)_searchController {
    NSString *searchText = _searchController.searchBar.text;
    if (searchText.length>=3) {
        [geoNames findPlacesWithCharacters:searchText];
    } else {
        filteredCities = [NSArray new];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPresentSearchController:(UISearchController *)_searchController {
    [_searchController.searchBar becomeFirstResponder];
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (filteredCities.count) {
        [searchController.searchBar resignFirstResponder];
    }
}

#pragma mark - Internal methods

- (void)exit {
    [searchController setActive:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GeoNames events

SUBSCRIBE(GNEGetPlaces) {
    if (event.error) {
        return;
    }
    
    filteredCities = [NSArray arrayWithArray:event.locations];
    
    [self.tableView reloadData];
}

#pragma mark - Appearance

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
