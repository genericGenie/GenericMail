//
//  MailManager.h
//  GenericMail
//
//  Created by Eric Lam on 4/17/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailCore/MailCore.h"

/**
 Manages the Fetching the mail using the HostSettingsModel
 */
@interface MailManager : NSObject
{
    /** MailCore2 Object Session which holds the MailSession */
    MCOIMAPSession *_MailCoreSession;
    /** This array represents the message body divided into parts */
    __block NSMutableArray *_msgBodyArr;
    /** This array represents the message headers */
    __block NSMutableArray *_msgHeaderArr;
    /** This array represents the message unique identifiers defined by the server storing the messages */
    __block NSMutableArray *_fetchUIDs;
    /** This temporary array holds the message dates or subjects */
    __block NSMutableArray *_tempArray;
    /** This is the private dictionary containing the host information */
    NSDictionary *_hostSettings;
    /** Validate that the headers were loaded successfully */
    __block BOOL isSettingsValid;
    /** Contains the list item number of the account in the pList array */
    NSInteger listItemNumber;
}



/** This is the locally default initializer */
//- (instancetype)init;

/** This is the locally shared instance */
+ (instancetype)sharedInstance;

/** This will get the locally stored copy of the User defaults.
 @code
 NSDictionary *dict = [MailManager sharedInstance] getSettingsCopy];
 @endcode
 @return [NSDictionary copy]
 */
- (NSDictionary *)getSettingsCopy;

/** Responsible to retrieve the dates for all fetched messages
 @param NSInteger number of dates and time strings within the messages
 @code
 NSArray *arr = [[MailManager sharedInstance] getDates:10];
 @endcode
 @return [NSArray copy]
 */
- (NSArray *)getDates:(NSInteger)numberOfDates;

/** Responsible to retrieve the subjects for all fetched messages
 @param NSInteger number of subject strings within the messages
 @code
 NSArray *arr = [[MailManager sharedInstance] numberOfSubjects:10];
 @endcode
 @return [NSArray copy]
 */
- (NSArray *)getSubjects:(NSInteger)numberOfSubjects;

/** Check whether login settings test was successful
 @code
 BOOL IsLoginSettingsAccepted = [[MailManager sharedInstance] isValidSettings];
 @endcode
 @return true or false
 */
- (BOOL)isValidSettings;

/** Record and save login setting. Attempt to login to the mail server and then set isSettingsValid
 @code
 [[MailManager sharedInstance] checkSettingsRequest];
 @endcode
 */
- (void)checkSettingsRequest;

/**
 Get the specific message by index in HTML format
 @param index the index that specify the messagesArray[index]
 @code
 NSString *HTMLmessage = [[MailManager sharedInstance] getHTMLMessageBodyByIndex:5];
 @endcode
 @return NSString
 */
- (NSString *)getHTMLMessageBodyByIndex:(NSInteger)index;

/**
 Retain the listItemNumber of the selection defined in the SettingsViewController
 @parma NSInteger number of the list item numbering from 0...?
 @code
 [[MailManager sharedInstance] setAccount:5];
 @endcode
 */
- (void)setAccount:(NSInteger)listItem;

/**
 Get all mail messages within the Inbox in a single fetch request.
 Store the headers and body of the messages
 This contains most of the MailCore code to get every part of a message except for the attachments
 Gmail usually downloads the headers first, then the message body second, third the user
 will manually request for file attachments and large images.
 @param numMsgs specific number of messages to retrieve
 @code
 [[MailManager sharedInstance] requestMessages:10];
 @endcode
 */
- (void)requestMessages:(NSInteger)numMsgs;


@end




