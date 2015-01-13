//
//  SystemManager.h
//  GenericMail
//
//  Created by Eric Lam on 4/17/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Manages the local AppDelegate sharedInstances
 
 Utilize Best Software Coding Practice to avoid conflicts with multiple methods using the following:
 @code
 [[UIApplication sharedApplication] delegate]
 [[NSBundle mainBundle] delegate]
 [[NSUserDefaults standardUserDefaults] delegate]
 [[NSURLCache sharedURLCache] delegate]
 @endcode
 This singleton class is designed specifically to counteract this issue.
 
 */
@interface LocalManager : NSObject
{
    /** This is the locally shared instance of the UIApplication */
    UIApplication *_thisLocalApp;
    /** This is the locally shared instance of the NSBundle */
    NSBundle *_thisLocalBundle;
    /** This is the locally shared instance of the NSUserDefaults */
    NSUserDefaults *_thisLocalDefaults;
    /** locally shared instance of the NSURLCache */
    NSURLCache *_thisURLCache;
    /** locally shared instance of the NSFileManager */
    NSFileManager *_thisFileManager;
}

/** This is the locally default initializer */
//- (instancetype)init;

/** This is the locally shared instance */
+ (instancetype)sharedInstance;

/** This is the equivalent instance of [UIApplication sharedApplication].
 Example usage:
 @code
 [[[LocalManager sharedInstance] thisApp] delegate];
 @endcode
 @return instanceof UIApplication
 */
- (UIApplication *)thisApp;

/** This is the equivalent instance of [NSBundle mainBundle].
 Example usage:
 @code
 [[[LocalManager sharedInstance] thisBundle] delegate];
 @endcode
  @return instanceof NSBundle
 */
- (NSBundle *)thisBundle;

/** This is the equivalent instance of [NSUserDefaults standardUserDefaults].
 Example usage:
 @code
 [[[LocalManager sharedInstance] thisDefaults] delegate];
 @endcode
  @return instanceof NSUserDefaults
 */
- (NSUserDefaults *)thisDefaults;

/** This is the equivalent instance of [NSURLCache sharedURLCache]
 Example usage:
 @code
 [[[LocalManager sharedInstance] thisURLCache] delegate];
 @endcode
 @return instanceof NSURLCache
 */
- (NSURLCache *)thisURLCache;

/** This is the equivalent instance of [NSFileManager defaultManager]
 Example usage:
 @code
 [[[NSFileManager sharedInstance] defaultManager] delegate]
 @endcode
 @return instanceof NSFileManager
 */
- (NSFileManager *)thisFileManager;
@end
