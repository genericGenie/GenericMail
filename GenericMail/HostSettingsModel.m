//
//  HostSettingsModel.m
//  GenericMail
//
//  Created by Eric Lam on 4/17/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import "HostSettingsModel.h"
#import "LocalManager.h"

/*

 */

@implementation HostSettingsModel

+ (instancetype)sharedInstance
{
    static dispatch_once_t lockToken;
    static HostSettingsModel *sharedInstance;
    dispatch_once(&lockToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _labelKeys = @[ @"hostname", @"port", @"username", @"password" ];
        // Get Dictionary[@"DefaultAccountData"] from the GenericMail-Info.plist file
        _defaultSettings = [[[LocalManager sharedInstance] thisBundle] objectForInfoDictionaryKey:@"DefaultAccountData"];
        // Get DIctionary contained within the "UserSettings.plist" file.
        NSString *plistPath = [[[LocalManager sharedInstance] thisBundle] pathForResource:@"UserSettings" ofType:@"plist"];
        NSDictionary *tmp = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSArray *arr = [NSArray arrayWithArray:tmp[@"Data0"]];
        numberOfSettings = [arr count];
        _settings = (NSDictionary *)arr[0];
        
        // Should the user-settings be empty, then fill it with defaults settings
        if ( [arr count] == 0 )
            _settings = [_defaultSettings copy];
    }
    return self;
}

- (NSDictionary *)getDefaultSettingsByIndexCopy:(NSInteger)index
{
    if (!_defaultSettings)
        _defaultSettings = [NSDictionary dictionary];
    NSDictionary *tmp = [[[LocalManager sharedInstance] thisBundle] objectForInfoDictionaryKey:@"DefaultAccountData"];
    NSArray *arr = [NSArray arrayWithArray:tmp[@"Data0"]];
    if ([arr count] >= index)
        _defaultSettings = (NSDictionary *)arr[index];
    else
        _defaultSettings = (NSDictionary *)arr[0];
    return _defaultSettings;
}


- (NSDictionary *)getUserSettingsByIndexCopy:(NSInteger)index
{
    NSDictionary *oldSettings = [[[LocalManager sharedInstance] thisBundle] objectForInfoDictionaryKey:@"DefaultAccountData"];
    if (!_settings)
        _settings = [NSDictionary dictionary];
    NSDictionary *dict = [NSDictionary dictionary];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"MySettings.plist"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];  // Root
    else
    {
        // Doesn't exist, start with the default dictionary
        dict = [NSMutableDictionary dictionaryWithDictionary:oldSettings];
        if ([dict writeToFile:path atomically:YES])
            NSLog(@"Created a new User Settings pList file");
    }
    NSArray *arr = [NSArray arrayWithArray:dict[@"Data0"]];

    if ([arr count] >= index)
        _settings = (NSDictionary *)arr[index];
    else
        _settings = (NSDictionary *)arr[0];
    return _settings;
}

- (NSArray *)getDefaultSettingsKeys
{
    return _labelKeys;
}



- (void)setUserSettings:(NSDictionary *)userSettings atIndex:(NSInteger)index
{
    NSDictionary *oldSettings = [[[LocalManager sharedInstance] thisBundle] objectForInfoDictionaryKey:@"DefaultAccountData"];
    if (!_settings)
        _settings = [NSDictionary dictionary];

    NSDictionary *dict = [NSDictionary dictionary];
//        _settings = [NSDictionary dictionaryWithDictionary:userSettings];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"MySettings.plist"];

    NSLog(@"File Path: %@", path);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];  // Root
    else
    {
        // Doesn't exist, start with the default dictionary
        dict = [NSMutableDictionary dictionaryWithDictionary:oldSettings];
        if ([dict writeToFile:path atomically:YES])
            NSLog(@"Created a new User Settings pList file");
    }
    
    NSLog(@"plist: %@", [dict description]);

    NSArray *Data0 = [NSArray arrayWithArray:dict[@"Data0"]];
//    NSArray *Data0 = [NSArray arrayWithObject:dict];
    NSDictionary *saveDict = @{
                               _labelKeys[0]:userSettings[_labelKeys[0]],  // Hostname
                               _labelKeys[1]:userSettings[_labelKeys[1]],  // Port
                               _labelKeys[2]:userSettings[_labelKeys[2]],  // Username
                               _labelKeys[3]:userSettings[_labelKeys[3]]   // Password
                               };
    // Search the pList for an existing username or password
    NSSet *CheckSet = [NSSet setWithObjects:userSettings[@"username"], userSettings[@"password"], nil];
    NSPredicate *searchUsername = [NSPredicate predicateWithFormat:@"any self.@allValues in %@" , CheckSet];
    NSArray *tmp = [Data0 filteredArrayUsingPredicate:searchUsername];
    NSLog(@"Existing Username = %@", [tmp description]);

    NSMutableArray *marr = [NSMutableArray arrayWithArray:Data0];
    marr[index] = saveDict;
//        [marr insertObject:saveDict atIndex:index];
    Data0 = [marr copy];
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    mdict[@"Data0"] = Data0;
    dict = [mdict copy];
    // write plist to disk
    if ([dict writeToFile:path atomically:YES])
        NSLog(@"User Settings saved to the first dictionary");
    else
        NSLog(@"User Settings not saved.");

}

- (NSInteger)getNumberOfSettings
{
    return numberOfSettings;
}

@end

