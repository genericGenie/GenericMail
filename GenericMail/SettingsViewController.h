//
//  SettingsViewController.h
//  GenericMail
//
//  Created by Eric Lam on 4/7/14.
//  Copyright (c) 2014 Eric Lam. All rights Preserved 20000 B.C.
//

#import <UIKit/UIKit.h>

/**
 Generic protocol for sharing settings information between classes, this is not really used
 */
@protocol SettingsProtocol <NSObject>
@required
- (void)processCollectedData:(NSDictionary *)settings;
@end

/** Gathers login settings to be displayed and saved to fetch mail messages */
@interface SettingsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    /** loading animation to temporarily replace the save button during the fetch mail operation */
    UIActivityIndicatorView *spinner;
    
    /** contains the original view configuration of the save button to restored at a later time */
    UIBarButtonItem *originalSaveButton;
}

/** This is the locally stored settings saved/retrieved from UserSettings.plist */
@property (strong, nonatomic) NSDictionary *UserSettings;

/** This is the factory default settings saved/retrieved from Generic-Info.plist */
@property (strong, nonatomic) NSDictionary *DefaultSettings;

/** This is the hostname of the IMAP server to connect to. */
@property (weak, nonatomic) IBOutlet UITextField *hostName;

/** This is the port number of the IMAP server to connect to. */
@property (weak, nonatomic) IBOutlet UITextField *portNumber;

/** This is the username of the login. */
@property (weak, nonatomic) IBOutlet UITextField *userName;

/** This is the password of the login. */
@property (weak, nonatomic) IBOutlet UITextField *passwordName;

/** Save button will unwind segue back to MailViewController and refresh the mail list */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SaveButton;

/** Cancel button unwind segue back to the MailViewController */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancelButton;

/** Restore the first Default login information stored in the pList */
@property (weak, nonatomic) IBOutlet UIButton *RestoreDefaultsButton;

/** Equivalent to the listbox to display a column of login items to be used */
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


/** Used externally for delegate message calling */
- (void)retrieveSettings;

/** Save button which saves the contents in memory,
 fetch Mail messages based on the defined login, 
 and unwind back to the Mail View */
- (IBAction)returnToMailView:(id)sender;

/** Cancel button, nothing done here */
- (IBAction)cancelSettings:(id)sender;

// chuck this later on, just used as a placeholder
@property (nonatomic, strong) NSMutableArray *settingsArr;

// This was used in the past to pass messages, but left here as a just in case feature
@property (nonatomic, weak) id <SettingsProtocol> delegate;



@end
