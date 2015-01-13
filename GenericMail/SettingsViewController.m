//
//  SettingsViewController.m
//  GenericMail
//
//  Created by Eric Lam on 4/7/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import "SettingsViewController.h"
#import "HostSettingsModel.h"
#import "LocalManager.h"
#import "MailManager.h"

@interface SettingsViewController ()
{
    /** temporary array */
    NSArray *tmp;
    /** temporary hold the picker selected index */
    NSInteger accountPicked;
    /** holds the original loaded account for comparing */
    NSString *usernameTemp;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *settingScrollView;
@end

@implementation SettingsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Register to recieve successful fetch notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Request Successful"
                                               object:nil];
    // Register to recieve failed fetch notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Request Failed"
                                               object:nil];
    // Prepare the loading spinner animation
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;

    /// Debug string to test whether delegate is functional
    self.settingsArr = [[NSMutableArray alloc]initWithObjects:
              @"Data 1 in array",@"Data 2 in array",@"Data 3 in array",
              @"Data 4 in array",@"Data 5 in array",@"Data 5 in array",
              @"Data 6 in array",@"Data 7 in array",@"Data 8 in array",
              @"Data 9 in array", nil];
    ////////////////////////////////////////
    ////////////////////////////////////////
    ////////////////////////////////////////
    
    [self.pickerView setBackgroundColor:[UIColor orangeColor]];
    
    // Make keyboard go away in various ways
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [self.settingScrollView addGestureRecognizer:tapScroll];
//    self.settingScrollView.canCancelContentTouches = YES;
    self.settingScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // Get the first login settings and display it
    tmp = [NSArray arrayWithObject:[[HostSettingsModel sharedInstance] getUserSettingsByIndexCopy:0]];
    self.UserSettings = tmp[0];
    tmp = [NSArray arrayWithObject:[[HostSettingsModel sharedInstance] getDefaultSettingsByIndexCopy:0]];
    self.DefaultSettings = tmp[0];
    // Hold the textboxes labels
    tmp = [[HostSettingsModel sharedInstance] getDefaultSettingsKeys];

    // indent text in UITextFields
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.hostName setLeftViewMode:UITextFieldViewModeAlways];
    [self.hostName setLeftView:spacerView];
    spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.portNumber setLeftViewMode:UITextFieldViewModeAlways];
    [self.portNumber setLeftView:spacerView];
    spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.userName setLeftViewMode:UITextFieldViewModeAlways];
    [self.userName setLeftView:spacerView];
    spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.passwordName setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordName setLeftView:spacerView];
    spacerView = nil;
    
    // assign values to textboxes
    self.hostName.text = self.UserSettings[tmp[0]];
    self.portNumber.text = self.UserSettings[tmp[1]];
    self.userName.text = self.UserSettings[tmp[2]];
    self.passwordName.text = self.UserSettings[tmp[3]];
//    self.passwordName.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // UnRegister notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Request Successful" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Request Failed" object:nil];
}

#pragma mark - NSNotificationCenter message

- (void)receivedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"Request Successful"])
    {
        NSLog(@"Recieved Messages from server");
        // Stop animating the spinner
        [spinner stopAnimating];
        // Send a message back to the MailViewController to refresh the tableView
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Refresh Messages" object:nil];
        // Return to MailViewController by Unwinding segue manually
        [self performSegueWithIdentifier:@"exitToMailView" sender:self];
    }
    else if ([[notification name] isEqualToString:@"Request Failed"])
    {
        NSLog(@"Server not responding");
        // Display a popup notifiying that the fetch failed
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verifying Mail"
                                                        message:@"Mail not responding. Please fill out the fields correctly."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert setTintColor:[UIColor redColor]];
        [alert show];
        // Stop the spinner animation
        [spinner stopAnimating];
        // Reset the Save button to its original configuration
        self.SaveButton.customView = originalSaveButton.customView;
        // Re-Enable all controls with red text
        self.RestoreDefaultsButton.enabled = YES;
        self.RestoreDefaultsButton.userInteractionEnabled = YES;
        self.hostName.enabled = YES;
        self.hostName.userInteractionEnabled = YES;
        self.portNumber.enabled = YES;
        self.portNumber.userInteractionEnabled = YES;
        self.userName.enabled = YES;
        self.userName.userInteractionEnabled = YES;
        self.passwordName.enabled = YES;
        self.passwordName.userInteractionEnabled = YES;
        self.pickerView.userInteractionEnabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate implementations

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // make the keyboard go away
    [textField resignFirstResponder];
    return YES;
}

//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.settingScrollView resignFirstResponder];
//}
#pragma mark - UITapGestureRecognizer

- (void)tapped
{
    [self.view endEditing:YES];
}

/**
 RestoreDefaults button
 Restore default data from plist
 
 @param (id) SettingsViewController
 
 */
- (IBAction)RestoreDefaults:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"MySettings.plist"];
    NSError *error;
    // Remove the User Settings pList file
    [[[LocalManager sharedInstance] thisFileManager] removeItemAtPath:path error:&error];
//    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    // Set all textboxes to their original contents
    tmp = [NSArray arrayWithArray:[[HostSettingsModel sharedInstance] getDefaultSettingsKeys]];
    if (![self.DefaultSettings isEqualToDictionary:self.UserSettings])
        self.UserSettings = [self.DefaultSettings copy];
    self.hostName.text = self.UserSettings[tmp[0]];
    self.portNumber.text = self.UserSettings[tmp[1]];
    self.userName.text = self.UserSettings[tmp[2]];
    self.passwordName.text = self.UserSettings[tmp[3]];
    // reload the pickerView
    [self.pickerView reloadAllComponents];
    tmp = nil;
}

// This is no longer needed because it is already handled by scrollView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView * txt in self.view.subviews)
    {
        // touch somewhere else and tell keyboard to get lost
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder])
            [txt resignFirstResponder];
        if ([txt isKindOfClass:[UIPickerView class]] && [txt isFirstResponder])
             [self.settingScrollView resignFirstResponder];
    }
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}



// returns the # of rows in each component..

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [[HostSettingsModel sharedInstance] getNumberOfSettings];
}

#pragma mark - UIPickerView Delegate


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = [NSString stringWithFormat:@"%@", [[HostSettingsModel sharedInstance] getDefaultSettingsKeys][2]];
    return (NSString *)[[HostSettingsModel sharedInstance] getUserSettingsByIndexCopy:row][str];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Populate the textboxes depending on row number
    NSArray *arr = [[HostSettingsModel sharedInstance] getDefaultSettingsKeys];
    NSDictionary *dict = [[HostSettingsModel sharedInstance] getUserSettingsByIndexCopy:row];
    self.hostName.text = dict[arr[0]];
    self.portNumber.text = dict[arr[1]];
    self.userName.text = dict[arr[2]];
    self.passwordName.text = dict[arr[3]];
    // save which was picked
    accountPicked = row;
}




#pragma mark - Settings Protocol

// delegate call that will probably be used in the future to share data between controllers, but not now
- (void)retrieveSettings
{
    //[self.delegate processCollectedData:self.UserSettings];
}

#pragma mark - Navigation Bar Buttons

- (IBAction)returnToMailView:(id)sender
{
    NSArray *arr = [[HostSettingsModel sharedInstance] getDefaultSettingsKeys];
    // trim whitespace characters
    NSDictionary *dict = @{ arr[0]:self.hostName.text,
                            arr[1]:self.portNumber.text,
                            arr[2]:self.userName.text,
                            arr[3]:self.passwordName.text
                          };
    // trim whitespace from the text
    __block NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        NSString *trimmedStr = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [tempDict setValue:trimmedStr forKey:key];
    }];
    // set the new session login credentials
    [[HostSettingsModel sharedInstance] setUserSettings:tempDict atIndex:accountPicked];
    // set the account picked
    [[MailManager sharedInstance] setAccount:accountPicked];
    // login and get messages, this is done asynchronously on a background thread
    [[MailManager sharedInstance] requestMessages:NUMMSGS];
    
    // save a copy of the original save button to restore it later
    originalSaveButton = [[UIBarButtonItem alloc] initWithCustomView:[self.SaveButton.customView copy]];
    // replace the current "Save" button with the loading spinner animation
    self.SaveButton.customView = spinner;
    [spinner startAnimating];
    
    // refresh the pickerview
    [self.pickerView reloadAllComponents];
    
    // Disable all controls
    self.RestoreDefaultsButton.enabled = NO;
    self.RestoreDefaultsButton.userInteractionEnabled = NO;
    self.hostName.enabled = NO;
    self.hostName.userInteractionEnabled = NO;
    self.portNumber.enabled = NO;
    self.portNumber.userInteractionEnabled = NO;
    self.userName.enabled = NO;
    self.userName.userInteractionEnabled = NO;
    self.passwordName.enabled = NO;
    self.passwordName.userInteractionEnabled = NO;
    self.pickerView.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
/////// Multithreading code for debugging - fun stuff
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC));
//    dispatch_after(timeout, dispatch_get_main_queue(), ^{
//        if (dispatch_semaphore_wait(semaphore, timeout))
//            NSLog(@"Waiting for 2: timed out");
//        else
//            NSLog(@"Waiting for 2: caught signal");
//
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if ([[MailManager sharedInstance] isValidSettings])
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"Grabbed new message");
//
//                [self performSegueWithIdentifier:@"exitToMailView" sender:self];
//            });
//        else
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"Couldn't get messages");
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verifying Mail"
//                                                                message:@"Mail not responding. Please fill out the fields correctly."
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:@"OK", nil];
//                [alert setTintColor:[UIColor redColor]];
//                [alert show];
//            });
//    });
}

- (IBAction)cancelSettings:(id)sender
{
    // do nothing
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
