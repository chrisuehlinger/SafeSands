//
//  UVIndex.h
//  SafeSands
//
//  Created by Christopher Uehlinger on 4/16/12.
//  Copyright (c) 2012 Loyola University Maryland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SandsParser.h"

@protocol UVIndexDelegate <NSObject>

-(void)foundUVIndex;

@end


@interface UVIndex : NSObject<SandsParserDelegate>{
    id<UVIndexDelegate> delegate;
    CLPlacemark *placemark;
    bool uvAlert;
    NSDate *forecastDate;
    NSNumber *index;
    
    SandsParser *indexParser;
    NSArray *fieldElements;
}

@property (strong, nonatomic) id<UVIndexDelegate> delegate;
@property (strong, nonatomic) CLPlacemark *placemark;

@property bool uvAlert;
@property (strong, nonatomic) NSDate *forecastDate;
@property (strong, nonatomic) NSNumber *index;


-(id)initWithPlacemark:(CLPlacemark *)p andDelegate:(id<UVIndexDelegate>)del;

@end
