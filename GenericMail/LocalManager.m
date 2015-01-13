//
//  SystemManager.m
//  GenericMail
//
//  Created by Eric Lam on 4/17/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import "LocalManager.h"

@implementation LocalManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t lockToken;
    static LocalManager *sharedInstance;
    dispatch_once(&lockToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _thisLocalApp = [UIApplication sharedApplication];
        _thisLocalBundle = [NSBundle mainBundle];
        _thisLocalDefaults = [NSUserDefaults standardUserDefaults];
        _thisURLCache = [NSURLCache sharedURLCache];
        _thisFileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (UIApplication *)thisApp
{
    if (!_thisLocalApp)
        return nil;
    return _thisLocalApp;
}

- (NSBundle *)thisBundle
{
    if (!_thisLocalBundle)
        return nil;
    return _thisLocalBundle;
}

- (NSUserDefaults *)thisDefaults
{
    if (!_thisLocalDefaults)
        return nil;
    return _thisLocalDefaults;
}

- (NSURLCache *)thisURLCache
{
    if (!_thisURLCache)
        return nil;
    return _thisURLCache;
}

- (NSFileManager *)thisFileManager
{
    if (!_thisFileManager)
        return nil;
    return _thisFileManager;
}



@end
