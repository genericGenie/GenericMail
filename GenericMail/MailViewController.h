//
//  MailViewViewController.h
//  GenericMail
//
//  Created by Eric Lam on 4/6/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailCore/MailCore.h"
#import "MailManager.h"
#import "SettingsViewController.h"


/**
 This is the class that contains the message list
 */
@interface MailViewController : UIViewController <SettingsProtocol, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate>
{
    /** Contains each message date */
    NSArray *msgDates;
    /** Contains each subject name */
    NSArray *msgSubjects;
    /** Each element is a HTML String of the message body */
    NSMutableArray *msgBodyArr;
    /** Originally designed to contain the login information passed from an unwind segue */
    NSDictionary *settings;
    /** Temporarily holds the default configured BarButtonItem, to be restored at a later time */
    UIBarButtonItem *originalRefreshButton;
    /** Loading indicator to replace the refresh button while the Mail is being fetched */
    UIActivityIndicatorView *spinner;
}
/** Lists out all the messages in rows */
@property (strong, nonatomic) IBOutlet UITableView *tableView;
/** Fetch a new list of message from the Mail server */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *RefreshButton;


@end
