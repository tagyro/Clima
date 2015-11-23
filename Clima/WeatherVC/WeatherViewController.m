//
//  WeatherViewController.m
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import "WeatherViewController.h"

#import "CityViewController.h"

#import "OpenWeather.h"

#import "GeoNames.h"

#import "Common.h"

#import <tolo/Tolo.h>

#import <FlickrKit/FlickrKit.h>

#import <CoreLocation/CoreLocation.h>

#import <AFNetworking/UIImageView+AFNetworking.h>

#import <FCIPAddressGeocoder/FCIPAddressGeocoder.h>

static NSString *const kLocation = @"defaultCity";

emptyImplementation(CVEGetPhotos)
emptyImplementation(CVELoadPhoto)

@interface WeatherViewController () {
    NSString *lat;
    NSString *lon;
    
    NSArray *photos;
    
    int index;
    
    BOOL useMetric;
    
    IBOutlet UIView         *container;
    IBOutlet UIImageView    *under;
    IBOutlet UIImageView    *over;
    
    IBOutlet UILabel        *cityLabel;
    IBOutlet UILabel        *temperatureLabel;
    IBOutlet UILabel        *unitLabel;
    IBOutlet UILabel        *descriptionLabel;
    
    IBOutlet UIVisualEffectView *effectView;
    
    UIDocumentInteractionController *docController;
}

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    REGISTER();
    
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:kFlickKey sharedSecret:kFlickrSecret];
    
    [self reloadWeatherInfo:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(nextPhoto)];
    
    [over addGestureRecognizer:tapGesture];
    
    useMetric = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
    effectView.layer.cornerRadius = 4.0f;
    effectView.layer.masksToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

#pragma mark - IBActions

- (IBAction)addCity:(id)sender {
    CityViewController *cityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addCityVC"];
    [self presentViewController:cityVC animated:YES completion:nil];
}

- (IBAction)export:(id)sender {
    UIGraphicsBeginImageContextWithOptions(container.bounds.size, 1, 0.0f);
    [container drawViewHierarchyInRect:container.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *filePath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[NSDate date]]] stringByAppendingPathExtension:@"png"];
    
    BOOL writen = [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:UIImagePNGRepresentation(snapshotImage)
                                          attributes:nil];
    
    if (writen) {
        docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
        //
        [docController presentOptionsMenuFromBarButtonItem:sender animated:YES];
    }
}

- (IBAction)reloadWeatherInfo:(id)sender {
    NSString *location = [[NSUserDefaults standardUserDefaults] objectForKey:kLocation];
    if (!isNull(location)) {
        [[OpenWeather sharedManager] requestWeatherForCity:location cached:NO];
    } else {
        [[FCIPAddressGeocoder sharedGeocoder] geocode:^(BOOL success) {
            if (success) {
                [[OpenWeather sharedManager] requestWeatherForCity:[FCIPAddressGeocoder sharedGeocoder].locationCity cached:YES];
            }
        }];
    }
}

#pragma mark - Internal methods

SUBSCRIBE(CVEGetPhotos) {
    index = 0;
    [self nextPhoto];
}

- (void)nextPhoto {
    if (isNull(photos) || !photos.count || over.alpha<.9) {
        return;
    }

    [UIView animateWithDuration:1
                     animations:^{
                         over.alpha = 0;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             NSURLRequest *req = [NSURLRequest requestWithURL:[photos objectAtIndex:arc4random() % photos.count]];
                             [over setImageWithURLRequest:req
                                         placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                             PUBLISH((({
                                                 CVELoadPhoto *event = [CVELoadPhoto new];
                                                 event.image = image;
                                                 event;
                                             })));
                                         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                             //
                                         }];
                         }
                     }];
    
    
}

SUBSCRIBE(CVELoadPhoto) {
    over.image = event.image;
    //
    [UIView animateWithDuration:2
                     animations:^{
                         over.alpha = 1;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             //
                         }
                     }];
}

#pragma mark - GeoNames event

SUBSCRIBE(GNESelectPlace) {
    
    [[OpenWeather sharedManager] requestWeatherForCity:event.location.toponymName cached:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:event.location.toponymName forKey:kLocation];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - OpenWeather events

SUBSCRIBE(OWEGetCurrent) {
    if (!isNull(event.error)) {
        // do something?
        return;
    }
    //
    cityLabel.text = event.city;
    
    // it seems that sometimes OpenWeather forgets to return the temperature
    temperatureLabel.text = event.weather.main.temp ? event.weather.main.temp : @"0 ";
    
    descriptionLabel.text = [event.weather.weather.firstObject desc];
    
    unitLabel.text = useMetric ? @"℃" : @"℉";
    
    // let's try and get a photo from flickr based on the current weather and location
    [self requestPhotosWithTags:[NSString stringWithFormat:@"%@,%@",[event.weather.weather.firstObject words],event.city]];
    //
}

#pragma mark - Flickr images

- (void)requestPhotosWithTags:(NSString*)tags {
    FlickrKit *fk = [FlickrKit sharedFlickrKit];
    
    FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
    
    search.tags = tags;
    search.tag_mode = @"all";
    search.sort = @"interestingness-desc";
//    search.content_type = @"1";
//    search.geo_context = @"2";
    
    [fk call:search completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            NSMutableArray *photoURLs = [NSMutableArray array];
            for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
                NSURL *url = [fk photoURLForSize:FKPhotoSizeLarge1024 fromPhotoDictionary:photoData];
                [photoURLs addObject:url];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                photos = [NSArray arrayWithArray:photoURLs];
                CVEGetPhotos *event = [CVEGetPhotos new];
                PUBLISH(event);
                
            });
        }

    }];
    
}

#pragma mark - Appearance

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
