//
//  curlswitchersettings.mm
//
//
//  Created by Keith on 8/17/13.
//
//
//  Handles the settings PSListController

#import <Foundation/Foundation.h>
#import <CoreFoundation/CFNotificationCenter.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UINavigationButton.h>
//#import <Preferences/PSListController.h>
//#import <Preferences/PSSpecifier.h>
//#import <Preferences/PSTableCell.h>
//#import <Preferences/PSTextEditingPane.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#include <stdio.h>

#define PREFS @"/User/Library/Preferences/com.eightbitace.curlswitcher.plist"

// Private declarations
@protocol PSBaseView <NSObject>
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
@end

@interface PSViewController : NSObject <PSBaseView>
-(void)presentViewController:(id)controller animated:(BOOL)animated completion:(id)arg3;
-(void)dismissViewControllerAnimated:(BOOL)animated completion:(id)arg3;
@end

@interface PSListController : PSViewController {
    NSArray* _specifiers;
}
-(void)reloadSpecifiers;
-(NSArray*)loadSpecifiersFromPlistName:(NSString*)plistName target:(id)target;
-(NSBundle*)bundle;
@end

@interface PSSpecifier : NSObject
@property(retain) NSString* name;
@property(retain) id titleDictionary;
@end

@interface curlswitchersettingsListController : PSListController <MFMailComposeViewControllerDelegate>

- (NSArray *) specifiers;
- (NSArray *) localizedSpecifiersForSpecifiers:(NSArray *)s;
- (void) sendMail:(id)param;
@property (nonatomic,retain) NSMutableDictionary *dict;

@end

@implementation curlswitchersettingsListController
@synthesize dict;

// Called when FAQ button pressed.
// Will open the FAQ webpage
-(void)openFAQ:(id)param
{
    NSString *faq = [NSString stringWithFormat:@"ComingSoon"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:faq]];
}

// Called when Mail button pressed.
// Opens email app with template and logs attached
-(void)sendMail:(id)param
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"CurlSwitcher"];
    
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:@"curlswitcher@eightbitace.com"];
    
    [picker setToRecipients:toRecipients];
    
    // Attach an image to the email
    NSString *path = @"/User/Library/Preferences/com.eightbitace.curlswitcher.plist";
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:myData mimeType:@"application/xml" fileName:@"curlswitcher.plist"];
    
    system("/usr/bin/dpkg -l >/tmp/dpkgl.log");
    NSString *path2 = @"/tmp/dpkgl.log";
    NSData *myData2 = [NSData dataWithContentsOfFile:path2];
    [picker addAttachmentData:myData2 mimeType:@"text/plain" fileName:@"dpkgl.log"];
    
    
    // Fill out the email body text
    NSString *emailBody = @"Please leave files attached. Email will be filtered if these lines are not removed.";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
    [picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec
{
	[super setPreferenceValue:value specifier:spec];
	[self reloadSpecifiers];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.eightbitace.curlswitcher.prefsUpdated"), NULL, NULL, true);
}

-(void)setEnabled:(id)value specifier:(id)specifier
{
	[self setPreferenceValue:value specifier:specifier];
	[self reloadSpecifiers];
}

- (id)specifiers
{
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"curlswitchersettings" target:self] retain];
		//_specifiers = [self localizedSpecifiersForSpecifiers:_specifiers];
	}
	
	return _specifiers;
}

- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s
{
    for(PSSpecifier *specifier in s)
    {
        if([specifier name])
            [specifier setName:[[self bundle] localizedStringForKey:[specifier name] value:[specifier name] table:nil]];
        
        if([specifier titleDictionary])
        {
            NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
            for(NSString *key in [specifier titleDictionary])
                [newTitles setObject: [[self bundle] localizedStringForKey:[[specifier titleDictionary] objectForKey:key] value:[[specifier titleDictionary] objectForKey:key] table:nil] forKey: key];
            
            [specifier setTitleDictionary: [newTitles autorelease]];
        }
    }
    
    return s;
}

@end

