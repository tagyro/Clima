//
//  GeoNames.h
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

#import <CoreLocation/CoreLocation.h>

#pragma mark - Models
@protocol GNMLocation @end
@interface GNMLocation : JSONModel
@property (strong, nonatomic) NSString *toponymName;
@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lng;
@property (nonatomic) int postalCode;
@end

@interface GNMPostalCodes : JSONModel
@property (strong, nonatomic) NSArray <GNMLocation> *geonames;
@end


#pragma mark - Events
@interface GNEvent : JSONModel
@property (strong, nonatomic) NSError *error;
@end

@interface GNEGetPlaces : GNEvent
@property (strong, nonatomic) NSArray <GNMLocation> *locations;
@end

@interface GNESelectPlace : GNEvent
@property (strong, nonatomic) GNMLocation *location;
@end

#pragma mark - Interface

@interface GeoNames : NSObject

- (instancetype)initWithUsername:(NSString*)username __attribute__((nonnull));

- (void)findPlacesWithCharacters:(NSString*)characters __attribute__((nonnull));

@end
