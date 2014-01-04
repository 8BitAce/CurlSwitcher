//
//  CSSettings.m
//
//
//  Created by Keith on 8/17/13.
//
//

#import "CSSettings.h"

static CSSettings *singletonCSSettings = nil;
static NSString* prefsPath = @"/User/Library/Preferences/com.eightbitace.curlswitcher.plist";

static void updatePrefs(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
{
    // Preferences changed, load them.
    [[CSSettings sharedCSSettings] loadSettings];
}


// Hooks notifications to get notified of changes to preferences
static void hookNotifications()
{
	CFNotificationCenterAddObserver(
                                    CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL, 
                                    updatePrefs,
                                    (CFStringRef)@"com.eightbitace.curlswitcher.prefsUpdated",
                                    NULL,
                                    CFNotificationSuspensionBehaviorHold
                                    );
}

@implementation CSSettings

@synthesize turnAngle=_turnAngle;
@synthesize turnDistance=_turnDistance;

+(CSSettings*)sharedCSSettings {
	@synchronized(self) {
		if (!singletonCSSettings) {
			singletonCSSettings = [[CSSettings alloc] init];
		}
	}
	return singletonCSSettings;
}

-(id)init
{
    if(self=([super init]))
    {
        [self loadSettings];
        hookNotifications();
    }
    return self;
}

// Gets settings from dictionary and loads them in singleton
-(void)loadSettings
{
    // Defaults
    _turnAngle = 1.0;
    _turnDistance = 0.6;

	NSDictionary* settings = [[NSDictionary alloc] initWithContentsOfFile: prefsPath];


	if (settings) {
		//[settings autorelease];
        
        if ([settings objectForKey:@"CSTurnAngle"])
			_turnAngle = [[settings objectForKey:@"CSTurnAngle"] doubleValue];
		
		if ([settings objectForKey:@"CSTurnDistance"])
			_turnDistance = [[settings objectForKey:@"CSTurnDistance"] doubleValue];
        
	} else {
        NSLog(@"No settings");
    }
    
    [settings release];
}



@end