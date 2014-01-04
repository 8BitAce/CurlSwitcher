//
//  CurlSwitcher.m
//  
//
//  Created by Keith on 8/17/13.
//
//

#import "CurlSwitcher.h"
#import "CSSettings.h"
#import <objc/runtime.h>
#import <math.h>

CSSettings *settings;

@implementation CSAnimationDelegate
-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if([[theAnimation valueForKey:@"id"] isEqual:@"curlDown"]){
        // View finished curling down, time to clean up!
        [(CurlSwitcher *)[[LAActivator sharedInstance] listenerForName:@"com.eightbitace.curlswitcher"] cleanup];
    }
}
@end

@implementation CurlSwitcher{
    CAFilter *filter;
    CSAnimationDelegate *animationDelegate;
}

@synthesize isAnimating = _isAnimating;
@synthesize linenView = _linenView;
@synthesize snapshotView = _snapshotView;
@synthesize curlPresent = _curlPresent;

// Initialize elements for effect
- (void)setupSwitcher
{
    // Showcase cannot be displayed when touches are active
    // Cancel all current touches
    [[UIApplication sharedApplication] _cancelAllTouches];
    SBGestureRecognizer *recognizer = [[objc_getClass("SBGestureRecognizer") alloc] init];
    recognizer.state = 4;
    //recognizer.sendsTouchesCancelledToApplication = YES;
    //[recognizer sendTouchesCancelledToApplicationIfNeeded];
    [recognizer release];
    // TODO: This is very hacky!
    [NSThread sleepForTimeInterval:.2];
    
    // Activate switcher without animation
    [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] _activateSwitcher:0.];
    
    // Get a reference to the switcher's superview's superview (appropriate view as was found in cycript)
    UIView *supView = [[[(SBAppSwitcherController*)[objc_getClass("SBAppSwitcherController") sharedInstance] view] superview] superview];
    
    // Adjust bounds for different orientations
    // TODO: Landscape is not working
    UIImageOrientation imageOrientation;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    switch((int)[[UIApplication sharedApplication] activeInterfaceOrientation]) {
        case UIInterfaceOrientationPortrait:
        default:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationRight;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationLeft;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
            }
            break;
    }
    CGRect appFrame = bounds;
    
    // Adjust frame for statusbar
    float barHeight = [(SBAppSwitcherController*)[objc_getClass("SBAppSwitcherController") sharedInstance] bottomBarHeight];
    appFrame.size.height = appFrame.size.height -  barHeight + 20;
    appFrame.origin.y = appFrame.origin.y - 20;
    
    // Create and display linen
    UIGraphicsBeginImageContext(appFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor scrollViewTexturedBackgroundColor] CGColor]);
    CGContextFillRect(context, appFrame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.linenView = [[[UIImageView alloc] initWithImage:img] autorelease];
    [supView addSubview:self.linenView];

    // Snapshot current view and place over switcher
    IOSurfaceRef ref = [UIWindow createScreenIOSurface];
    UIImage *snapshot = [[UIImage alloc] _initWithIOSurface:ref scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    self.snapshotView = [[[UIImageView alloc] initWithImage: snapshot] autorelease];
    CFRelease(ref);
    [snapshot release];
    [supView addSubview:self.snapshotView];
    
    // Let touches go to switcher, not our overlays
    [[(SBAppSwitcherController*)[objc_getClass("SBAppSwitcherController") sharedInstance] view] becomeFirstResponder];
    
    
    // Initialize curl filter
    filter = [CAFilter filterWithType:@"pageCurl"];
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:0] forKey:@"inputTime"];
    [filter setValue:[NSNumber numberWithFloat:-(settings.turnAngle)] forKey:@"inputAngle"];
}

// Perform curl up animation
-(void)curlUp
{
    // Add filter to |snapshotView|
    self.snapshotView.layer.filters = [NSArray arrayWithObject:filter];
    
    // Curl up |snapshotView|
    CABasicAnimation* curlUpAnimation = [CABasicAnimation animationWithKeyPath:@"filters.pageCurl.inputTime"];
    [curlUpAnimation setValue:@"curlUp" forKey:@"id"];
    curlUpAnimation.fromValue = [NSNumber numberWithFloat: 0.];
    curlUpAnimation.toValue = [NSNumber numberWithFloat: settings.turnDistance];
    curlUpAnimation.duration = 0.25;
    curlUpAnimation.fillMode = kCAFillModeForwards;
    curlUpAnimation.removedOnCompletion = NO;
    curlUpAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.snapshotView.layer addAnimation:curlUpAnimation forKey:@"curlUpAnimation"];
    _curlPresent = YES;
    
}

// Perform curl down animation
-(void)curlDown
{
    // Curl down |snapshotView|
    CABasicAnimation* curlDownAnimation = [CABasicAnimation animationWithKeyPath:@"filters.pageCurl.inputTime"];
    [curlDownAnimation setValue:@"curlDown" forKey:@"id"];
    curlDownAnimation.fromValue = [NSNumber numberWithFloat: settings.turnDistance];
    curlDownAnimation.toValue = [NSNumber numberWithFloat: 0.];
    curlDownAnimation.duration = 0.25;
    curlDownAnimation.fillMode = kCAFillModeForwards;
    animationDelegate = [[CSAnimationDelegate alloc] init];
    curlDownAnimation.delegate = animationDelegate;
    curlDownAnimation.removedOnCompletion = NO;
    curlDownAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.snapshotView.layer addAnimation:curlDownAnimation forKey:@"curlDownAnimation"];
}

// Destroy now uneeded elements
-(void)cleanup
{
    self.snapshotView.layer.filters = nil;
    _curlPresent = NO;
    [_linenView removeFromSuperview];
    self.linenView = nil;
    [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] dismissSwitcherAnimated:NO];
    [_snapshotView removeFromSuperview];
    self.snapshotView = nil;
    [animationDelegate release];
}

#pragma mark libactivator delegate

-(BOOL)dismiss
{
    if(self.snapshotView){
        [self curlDown];
        return YES;
    }
    return NO;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

    if(![self dismiss]){
        settings = [[CSSettings alloc] init];
        [self setupSwitcher];
        [self curlUp];
        // Set the event handled
        [event setHandled:YES];
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
    [self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event
{
    [self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event{
    if ([self dismiss])
        [event setHandled:YES];
}

+ (void)load
{
    @autoreleasepool {
        if (![[LAActivator sharedInstance] hasSeenListenerWithName:@"com.eightbitace.curlswitcher"]) {
            [[LAActivator sharedInstance] assignEvent:[LAEvent eventWithName:@"libactivator.menu.press.double"] toListenerWithName:@"com.eightbitace.curlswitcher"];
        }
        [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.eightbitace.curlswitcher"];
    }
}



@end
