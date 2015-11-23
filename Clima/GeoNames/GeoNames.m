//
//  GeoNames.m
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import "GeoNames.h"

#import <AFNetworking/AFNetworking.h>

#import <tolo/Tolo.h>

#import "Common.h"

@implementation GNMLocation

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

emptyImplementation(GNMPostalCodes)

emptyImplementation(GNEvent)

emptyImplementation(GNEGetPlaces)

emptyImplementation(GNESelectPlace)

@interface GeoNames () {
    AFHTTPRequestOperationManager *manager;
    
    NSString *uname;
}

@end

@implementation GeoNames

- (instancetype)initWithUsername:(NSString*)username {
    self = [super init];
    if (self) {
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kGeoNameURLString]];
        
        uname = username;
    }
    return self;
}

- (void)findPlacesWithCharacters:(NSString*)characters {
    if (isNull(characters)) {
        return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            uname, @"username",
                            characters, @"name_startsWith",
                            [NSNumber numberWithBool:true], @"isReduced",
                            [NSNumber numberWithBool:true], @"isNameRequired",
                            @"json",@"type",
                            @"relevance",@"orderby",
                            [NSNumber numberWithInt:10], @"maxRows", // limit to 10 results
                            @"P",@"featureClass",
                            nil];
    
    AFHTTPRequestOperation *getPlaces = [manager GET:@"search"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                 NSError *error;
                                                 GNMPostalCodes *locations = [[GNMPostalCodes alloc] initWithDictionary:responseObject error:&error];
                                                 
                                                 GNEGetPlaces *event = [GNEGetPlaces new];
                                                 event.error = error;
                                                 event.locations = locations.geonames;
                                                 PUBLISH(event);
                                                 
                                             } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                                 GNEGetPlaces *event = [GNEGetPlaces new];
                                                 event.error = error;
                                                 PUBLISH(event);
                                             }];
    
    [getPlaces resume];
}

@end
