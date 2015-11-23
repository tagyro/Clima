###Clima 

iOS app to show weather info (yes, another one, because there really aren't enough)  

![brasov](Screenshots/brasov.PNG =191x333)![miami](Screenshots/miami.PNG =191x333)![paris](Screenshots/paris.PNG =191x333)![torino](Screenshots/torino.PNG =191x333)![vienna](Screenshots/vienna.PNG =191x333)![warsaw](Screenshots/warsaw.PNG =191x333)

###Usage

1. Clone the repo and navigate to the `Clima` folder (where the Podfile is)  
2. `pod install` from the terminal  
3. Generate API Key for the services bellow and add them in the `Common.h` file (you'll see the warning)

]###Dependencies

The deployment target is iOS 8+ (probably could be 7+).  
Libraries/API's used:  
- [GeoNames API](http://geonames.org) to retrieve names of cities (see `GeoNames.h/.m`)  
- [OpenWeatherMap](http://openweathermap.org) API to retrieve the weather (doh) (see `OpenWeather.h/.m`)  
- [FCIPAddressGeocoder](https://github.com/fabiocaccamo/FCIPAddressGeocoder) to detect location from the IP (so you don't have to show that annoying iOS alert)  
- [FlickrKit] (https://github.com/devedup/FlickrKit) to show photos from [flickr](https://www.flickr.com)  
- [tolo](https://github.com/genzeb/tolo) an event publish/subscribe framework inspired by Otto  
- [JSONModel](https://github.com/icanzilb/JSONModel) - "Magical Data Modelling Framework for JSON" 
- [AMLocalized](https://github.com/tagyro/AMLocalizedString) - easy, on-the-fly changing of localization strings 
- and of course, [AFNetworking](https://github.com/AFNetworking/AFNetworking) - the delightful networking library for iOS and Mac OS X.

###Contributions
Submit pull requests, fork, send me a [tweet](https://twitter.com/andreistoleru) :)

###Notes

The initial background image is [Public  Domain](https://creativecommons.org/publicdomain/zero/1.0/) by [Nicholas A. Tonelli](https://www.flickr.com/photos/nicholas_t/) - Thank you!

The rest of the background images are loaded from [flickr](https://www.flickr.com), from a search on the weather and/or location. There is no endorsement by either [flickr](https://www.flickr.com) or the authors of these images.


###LICENSE
The code is released under GPLv3
