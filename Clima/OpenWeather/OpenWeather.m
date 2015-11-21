//
//  OpenWeather.m
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import "OpenWeather.h"

#import <AFNetworking/AFNetworking.h>

#define emptyImplementation(className)      @implementation className @end

emptyImplementation(OWMWeather)
emptyImplementation(OWMMain)
emptyImplementation(OWMWind)
emptyImplementation(OWMClouds)
emptyImplementation(OWEvent)
emptyImplementation(OWEGetCurrent)

@interface OpenWeather () {
    NSString *defaultLanguage;
    
    AFHTTPRequestOperationManager *manager;
}

@end

@implementation OpenWeather

static NSString *const kOWAPIKey = @"2de143494c0b295cca9337e1e96b00e0"; // 3d813e5adee2e1828648815f05d4e3fb

static NSString *const kBaseURL = @"http://api.openweathermap.org/data/2.5/";

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
        NSLog(@"OpenWeather language: %@",defaultLanguage);
        return;
    }
    
    NSString *key = [[[OpenWeather languages] allKeysForObject:language] firstObject];
    if (key) {
        defaultLanguage = key;
        NSLog(@"OpenWeather language: %@",defaultLanguage);
    } else {
        NSLog(@"Couldn't find the requested language \"%@\", see [OpenWeather languages] for a list of available options",language);
    }
}

- (void)requestWeatherForCity:(NSString*)city {
    
    if (isNull(city)) {
        return;
    }
    
    NSLog(@"language: %@",defaultLanguage);
    if (isNull(manager)) {
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            city, @"q",
                            defaultLanguage, @"lang",
                            kOWAPIKey, @"appid", nil];
    
    NSLog(@"requesting current weather with %@",params);
    
    AFHTTPRequestOperation *getCurrent = [manager GET:@"weather"
                                           parameters:params
                                              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                                  NSLog(@"response: %@",responseObject);
                                              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                                  // weather info is not something you usually want to cache
                                                  // but then again, we don't want to show users an empty screen, right?
                                                  // so we force a reload from cache (if available)
                                                  [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
                                                  [[OpenWeather sharedManager] requestWeatherForCity:city];
                                              }];
    
    [getCurrent resume];
    // we set the cache back to use server protocol
    [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
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
