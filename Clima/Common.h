//
//  Common.h
//  Clima
//
//  Created by Andrei Stoleru on 21/11/15.
//  Copyright © 2015 magooos. All rights reserved.
//

#ifndef Common_h
#define Common_h

#define emptyImplementation(className)      @implementation className @end

#error Register at https://www.flickr.com/services/api/misc.api_keys.html to generate API key
static NSString *const kFlickKey        = @"";
static NSString *const kFlickrSecret    = @"";

#error Register at http://www.geonames.org/ to generate API key
static NSString *const kGeoNameURLString = @"";
static NSString *const kGeoNameUsername = @"";

#error Register at http://openweathermap.org/
static NSString *const kOpenWeatherAPIKey = @"";

static NSString *const kOpenWeatherURLString = @"http://api.openweathermap.org/data/2.5/";

#endif /* Common_h */
