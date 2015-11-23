//
//  OpenWeather.m
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import "OpenWeather.h"

#import <AFNetworking/AFNetworking.h>

#import "Common.h"

@implementation OWMModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

emptyImplementation(OWMMain)
emptyImplementation(OWMWind)
emptyImplementation(OWMClouds)

@implementation OWMDescription

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]
            initWithDictionary:@{@"main": @"words",
                                 @"description": @"desc"}];
}

@end

emptyImplementation(OWMWeather)

emptyImplementation(OWEvent)
emptyImplementation(OWEGetCurrent)

@interface OpenWeather () {
    NSString *defaultLanguage;
    
    AFHTTPRequestOperationManager *manager;
}

@end

@implementation OpenWeather

static OpenWeather *_sharedManager;

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            _sharedManager = [[self alloc] init];
            //
        });
    }
    //
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        defaultLanguage = @"en";
    }
    return self;
}

#pragma mark - OWCalls

- (void)setLanguage:(NSString*)language {
    if (isNull(language)) {
        return;
    }
    
    NSString *value = [[OpenWeather languages] valueForKey:language];
    if (!isNull(value)) {
        defaultLanguage = value;
        return;
    }
    
    NSString *key = [[[OpenWeather languages] allKeysForObject:language] firstObject];
    if (key) {
        defaultLanguage = key;
    } else {
        NSLog(@"Couldn't find the requested language \"%@\", see [OpenWeather languages] for a list of available options",language);
    }
}

- (void)requestWeatherForCity:(NSString*)city cached:(BOOL)cached {
    
    if (isNull(city)) {
        return;
    }
    
    if (isNull(manager)) {
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kOpenWeatherURLString]];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    
    manager.requestSerializer.cachePolicy = cached ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReturnCacheDataElseLoad;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            city, @"q",
                            defaultLanguage, @"lang",
                            kOpenWeatherAPIKey, @"appid",
                            @"metric", @"units",
                            nil];
    
    AFHTTPRequestOperation *getCurrent = [manager GET:@"weather"
                                           parameters:params
                                              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                  //
                                                  NSError *error;
                                                  OWMWeather *weather = [[OWMWeather alloc] initWithDictionary:responseObject error:&error];
                                                  
                                                  OWEGetCurrent *event = [OWEGetCurrent new];
                                                  event.weather = weather;
                                                  event.error = error;
                                                  event.cached = cached;
                                                  event.city = city;
                                                  PUBLISH(event);
                                                  
                                              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                                  OWEGetCurrent *event = [OWEGetCurrent new];
                                                  event.error = error;
                                                  event.cached = cached;
                                                  PUBLISH(event);
                                              }];
    
    [getCurrent resume];
    
}


#pragma mark - Helper methods

+ (NSDictionary*)languages {
    
    static NSDictionary *OWlanguages = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OWlanguages = @{@"English":@"en",
                        @"Russian":@"ru",
                        @"Italian":@"it",
                        @"Spanish":@"es",
                        @"Ukrainian":@"uk",
                        @"German":@"de",
                        @"Portuguese":@"pt",
                        @"Romanian":@"ro",
                        @"Polish":@"pl",
                        @"Finnish":@"fi",
                        @"Dutch":@"nl",
                        @"French":@"fr",
                        @"Bulgarian":@"bg",
                        @"Swedish":@"sv",
                        @"Chinese Traditional":@"zh_tw",
                        @"Chinese Simplified":@"zh_cn",
                        @"Turkish":@"tr",
                        @"Croatian":@"hr",
                        @"Catalan":@"ca"};
    });
    
    return OWlanguages;
}

@end
