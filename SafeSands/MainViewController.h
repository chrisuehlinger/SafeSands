//
//  MainViewController.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 3/9/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController<CLLocationManagerDelegate, NSXMLParserDelegate>{
    // parser properties
    NSUInteger parsedItemsCounter;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    NSMutableDictionary *currentItemObject;
    NSMutableDictionary *currentFeedObject;
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
}

@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableDictionary *currentItemObject;
@property (nonatomic, retain) NSMutableDictionary *currentFeedObject;

@property (weak, nonatomic) IBOutlet UILabel *locationDisplay;
@property (weak, nonatomic) NSString *locationText;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@property (strong, nonatomic) NSURLConnection *weatherConnection;
@property (strong, nonatomic) NSMutableData *weatherData;
@end
