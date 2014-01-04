//
//  CSSettings.h
//
//
//  Created by Keith on 8/17/13.
//
//  Handles the settings of the tweak.

@interface CSSettings : NSObject
{
}

@property double turnAngle;
@property double turnDistance;

+(CSSettings*)sharedCSSettings;
-(void)loadSettings;

@end