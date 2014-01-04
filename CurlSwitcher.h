//
//  CurlSwitcher.h
//  
//
//  Created by Keith on 8/17/13.
//
//  Handles the main functionality of the tweak
//  including Activator delegate methods and implementing the effect

#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>


// Private declarations
@interface SBLinenView : UIView
-(id)initWithFrame:(struct CGRect)arg1;
@end

@interface SBShowcaseViewController : NSObject
@end

@interface SBGestureRecognizer : NSObject
-(void)sendTouchesCancelledToApplicationIfNeeded;

@property(nonatomic) int state;
@property(nonatomic) BOOL sendsTouchesCancelledToApplication;
@end

@interface CSAnimationDelegate : NSObject
@end

@interface SBAppSwitcherController : SBShowcaseViewController
+(id)sharedInstance;
-(UIView*)view;
-(float)bottomBarHeight;
@end

@interface SBUIController
+(id)sharedInstance;
-(void)_revealShowcase:(id)arg1 revealMode:(int)arg2 duration:(int)arg3 fromSystemGesture:(BOOL)arg4 revealSetupBlock:(id)arg5;
-(BOOL)_activateSwitcher:(double)arg1;
-(void)dismissSwitcherAnimated:(BOOL)arg1;
@end

@interface SBAlert : NSObject
@end

@interface SBAwayController:SBAlert
-(BOOL)isLocked;
+(id)sharedAwayController;
@end

@interface UIWindow ()
+(IOSurfaceRef)createScreenIOSurface;
@end

@interface UIImage ()
-(id)_initWithIOSurface:(IOSurfaceRef)arg1 scale:(float)arg2 orientation:(int)arg3;
@end

@interface UIApplication (cancelTouches)
-(void)_cancelAllTouches;
-(int)activeInterfaceOrientation;
@end

// Our stuff
@interface CurlSwitcher : NSObject <LAListener>

@property (nonatomic, retain) UIImageView *snapshotView;
@property (nonatomic, retain) UIImageView *linenView;
@property (nonatomic, readwrite) BOOL isAnimating;
@property (nonatomic, readwrite) BOOL curlPresent;

-(void)cleanup;

@end
