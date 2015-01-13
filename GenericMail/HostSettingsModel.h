//
//  HostSettingsModel.h
//  GenericMail
//
//  Created by Eric Lam on 4/17/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
Manages the host login settings
 */
@interface HostSettingsModel : NSObject
{
    /** This is the factory default settings saved/retrieved from Generic-Info.plist */
    NSDictionary *_defaultSettings;
    /** This is the locally stored settings saved/retrieved from UserSettings.plist */
    NSDictionary *_settings;
    /** NSDictionary keys that are identical to the labels on screen */
    NSArray *_labelKeys;
    /** Holds the number of settings */
    NSInteger numberOfSettings;
}

/** This is the locally default initializer */
//- (instancetype)init;

/** This is the locally shared instance */
+ (instancetype)sharedInstance;

/** This is the copy of the default Host settings.
 Example usage:
 @code
 NSDictionary *dict = [[HostSettingsModel sharedInstance] getDefaultSettingsByIndexCopy];
 @endcode
 @return [NSDictionary copy]
 */
- (NSDictionary *)getDefaultSettingsByIndexCopy:(NSInteger)index;

/** This is the copy of the user-defined host settings.
 Example usage:
 @code
 NSDictionary *dict = [[HostSettingsModel sharedInstance] getUserSettingsByIndexCopy];
 @endcode
 @return [NSDictionary copy]
 */
- (NSDictionary *)getUserSettingsByIndexCopy:(NSInteger)index;

/** This is the copy of the default setting labels in order.
 Example usage:
 @code
 NSDictionary *dict = [[HostSettingsModel sharedInstance] getDefaultSettingsKeys];
 @endcode
 @return [NSDictionary copy]
 */
- (NSArray *)getDefaultSettingsKeys;

/** Retrieve the saved user defined settings from the UserSettings.plist file
 @param userSettings override the existing user settings
 @param index array index containing the dictionary to save
 @code
 NSDictionary *dict = @{"hostname":"imap.gmail.com", "portname":"993", "username":"myusername", "password":"mypassword"}
 [[HostSettingsModel sharedInstance] setUserSettings:dict atIndex:2];
 @endcode
 */
- (void)setUserSettings:(NSDictionary *)userSettings atIndex:(NSInteger)index;

/** Returns the number of Settings in the pList file
 @return numberOfSettings NSInteger holding the number of settings
 */
- (NSInteger)getNumberOfSettings;

@end
