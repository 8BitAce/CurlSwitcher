//
//  Tweak.xm
//
//
//  Created by Keith on 8/15/13.
//
//  Method hooks.

#import <libactivator/libactivator.h>
#import "CurlSwitcher.h"

%hook SBUIController
// Called when application launched from switcher. Deactivate our event.
-(void)activateApplicationFromSwitcher:(id)arg1
{
    %orig(arg1);
    [[LAActivator sharedInstance] sendDeactivateEventToListeners: [LAEvent eventWithName:@"com.eightbitace.curlswitcher"]];
}

// Called when switcher is dismissed. Don't call %orig unless our effect 
// is NOT present.
-(void)_dismissShowcase:(double)arg1 unhost:(BOOL)arg2
{
    if([(CurlSwitcher *)[[LAActivator sharedInstance] listenerForName:@"com.eightbitace.curlswitcher"] curlPresent]){
        return;
    } else {
        %orig(arg1, arg2);
    }
}
%end

%hook SBAwayController
// Called when screen is (un)locked. If it is getting locked, deactivate
// our event.
-(void)setLocked:(BOOL)locked
{
    %orig;
    if(locked == YES){
        [[LAActivator sharedInstance] sendDeactivateEventToListeners: [LAEvent eventWithName:@"com.eightbitace.curlswitcher"]];
    }
}
%end