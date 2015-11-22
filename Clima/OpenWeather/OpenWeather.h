//
//  OpenWeather.h
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

#import <tolo/Tolo.h>

#pragma mark - Models

@protocol OWMMain @end
@interface OWMMain : JSONModel
@property (nonatomic) float temp;
@property (nonatomic) float temp_min;
@property (nonatomic) float temp_max;
@property (nonatomic) int humidity;
@end

@protocol OWMWind @end
@interface OWMWind : JSONModel
@property (nonatomic) float *speed;
@property (nonatomic) float *deg;
@end

@protocol OWMClouds @end
@interface OWMClouds : JSONModel
@property (nonatomic) int *all;
@end


@interface OWMWeather : JSONModel
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) OWMMain *main;
@property (strong, nonatomic) OWMClouds *clouds;
@property (strong, nonatomic) OWMWind *wind;
@end

#pragma mark - Events

@interface OWEvent : JSONModel
@property (strong, nonatomic) NSError *error; //
@end

@interface OWEGetCurrent : OWEvent
@property (strong, nonatomic) OWMWeather *weather;
@property (nonatomic) BOOL cached;
@end

#pragma mark - Interface

@interface OpenWeather : NSObject

- (instancetype)init __attribute__((unavailable("use [OpenWeather sharedManager]")));

- (instancetype)new __attribute__((unavailable("use [OpenWeather sharedManager]")));

// Instance methods

/**
 *  Sets the default language for the weather description
 *
 *  @param language Language name or code (Romanian or ro)
 */
- (void)setLanguage:(NSString*)language __attribute__((nonnull));

/**
 *  Calls OpenWeatherMap API to get the *current* weather for the specified city;
 *
 *  @param city The name of the city
 */
- (void)requestWeatherForCity:(NSString*)city cached:(BOOL)cached __attribute__((nonnull));

// Class methods
+ (instancetype)sharedManager;

/**
 *  Returns a list of available languages as a dictionary. You can use the keys (or the values) to pass to :setLanguage
 *
 *  @return Available language for OpenWeather weather info
 */
+ (NSDictionary*)languages;

@end
