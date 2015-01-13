//
//  MailViewViewController.m
//  GenericMail
//
//  Created by Eric Lam on 4/6/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import "MailViewController.h"
#import "MessageViewController.h"
#import "SettingsViewController.h"
#import "LocalManager.h"
#import "CustomCell.h"




@interface MailViewController ()
{
    NSString *CellIdentifier;
}

- (IBAction)refreshItems:(UIBarButtonItem *)sender;
@end

@implementation MailViewController


- (void)viewDidLoad
{
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
    
    // Register to recieve notification when the HOME button is pressed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResign)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    // Register to recieve notification when the application is brought back from the inactive(background) state
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.hidesWhenStopped = YES;
    
    CellIdentifier = @"CellID";
    msgBodyArr = [NSMutableArray array];
    settings = [NSDictionary dictionary];
    
    // use defaults and load the messages
    [[MailManager sharedInstance] requestMessages:NUMMSGS];
    msgSubjects = [NSArray arrayWithArray:[[MailManager sharedInstance] getSubjects:NUMMSGS]];
    msgDates = [NSArray arrayWithArray:[[MailManager sharedInstance] getDates:NUMMSGS]];
    [super viewDidLoad];

    // save a copy of the original save button to restore it later
    originalRefreshButton = [[UIBarButtonItem alloc] initWithCustomView:[self.RefreshButton.customView copy]];
    // replace the current "Save" button with the loading spinner animation
    self.RefreshButton.enabled = NO;
    self.RefreshButton.customView = spinner;
    [spinner startAnimating];
    // Disable the setting control
    self.navigationItem.leftBarButtonItem.enabled = NO;
//    [self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:CellIdentifier];
    
    if (msgSubjects == nil || [msgSubjects count] == 0)
        msgSubjects = @[@""];
    if (msgDates == nil || [msgDates count] == 0)
        msgDates = @[@""];
}

#pragma mark - Notification messages

- (void)applicationWillResign
{
    // Unregister Refresh messages notification while the App is in the background.
    // save some battery life by disabling some unneeded processes
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Refresh Messages" object:nil];
}

- (void)applicationDidBecomeActive
{
    // Register to recieve notifications for Refreshing messages
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Refresh Messages"
                                               object:nil];
}

- (void)receivedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"Refresh Messages"] || [[notification name] isEqualToString:@"Request Successful"])
    {
        // get the subjects and times
        msgSubjects = [NSArray arrayWithArray:[[MailManager sharedInstance] getSubjects:NUMMSGS]];
        msgDates = [NSArray arrayWithArray:[[MailManager sharedInstance] getDates:NUMMSGS]];
        // repopulate the tableView
        
        NSLog(@"Refresh Successful");
    }
    else if ([[notification name] isEqualToString:@"Request Failed"])
    {
        NSLog(@"Refresh Failed");
    }
    [self.tableView reloadData];
    // wait 2 seconds to allow the tableView to reload, then stop the spinner and restore the refresh button; avoids abusive constant refresh
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        self.RefreshButton.customView = originalRefreshButton.customView;
        self.RefreshButton.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    });
}

#pragma mark - Format Date and Time

- (NSString *)FormatDateAndTimeToCustomString:(NSString *)input
{
    NSString *str = [NSString stringWithFormat:@"%@",input];
    if ([str isEqual:@""])
        return @"Please Wait. Loading...";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    // Expected input format of date and time and timezone
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    NSDate *inputDate = [dateFormatter dateFromString:str];
    // Output date and time format we want
    dateFormatter.dateFormat = @"MMM dd, yyyy '@' hh:mm a";
    // Create a string with the timezone(EST or EDT) appended at the end
    str = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:inputDate], [[NSTimeZone localTimeZone] abbreviation]];
    return str;
}

#pragma mark - TableView messages

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([msgSubjects count] < NUMMSGS)
        msgSubjects = [[MailManager sharedInstance] getSubjects:NUMMSGS];
    if ([msgDates count] < NUMMSGS)
        msgDates = [[MailManager sharedInstance] getDates:NUMMSGS];
    if (msgSubjects == nil || [msgSubjects count] == 0)
        msgSubjects = @[@""];
    if (msgDates == nil || [msgDates count] == 0)
        msgDates = @[@""];

    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil)
    {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    // This is the subject of the Message
    cell.Title.text = [NSString stringWithFormat:@"%@", msgSubjects[row]];
    // Format the date and time to be more readable
    NSString *fmtDate = [self FormatDateAndTimeToCustomString:msgDates[row]];
    cell.SubTitle.text = [NSString stringWithFormat:@"%@", fmtDate];

    return (UITableViewCell *)cell;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"MessageView" sender:self];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger x;
    if ([msgSubjects respondsToSelector:@selector(count)])
         x = [msgSubjects count];
    return x = x > 0 ? x : 1;
//    return 20;
}

- (void) processCollectedData:(NSDictionary *)settingsViewSettings
{
    settings = [settingsViewSettings copy];
}


#pragma mark - SettingsViewController button from UnWindSegue presses

-(IBAction)savePressed:(UIStoryboardSegue *)sender
{

    UIView *sv = self.view;
    UIView *dv = ((UIViewController *)sender.destinationViewController).view;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    dv.center = CGPointMake(sv.center.x - sv.frame.size.width, dv.center.y);
    [window insertSubview:dv belowSubview:sv];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         dv.center = CGPointMake(sv.center.x,
                                                 dv.center.y);
                         sv.center = CGPointMake(sv.center.x + sv.frame.size.width,
                                                 dv.center.y);
                     }
                     completion:^(BOOL finished) {
                         [sender.destinationViewController dismissViewControllerAnimated:NO completion:nil];
                     }];

//    [self.navigationController popToRootViewControllerAnimated:NO];
//    [self.navigationController popViewControllerAnimated:YES];
//    SettingsViewController *srcViewController = sender.sourceViewController;
//    settings = [srcViewController.UserSettings copy];
    
    NSLog(@"Save Button Pressed");
}

-(IBAction)cancelPressed:(UIStoryboardSegue *)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
//    [self.navigationController popViewControllerAnimated:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1.00];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
    [UIView commitAnimations];

    SettingsViewController *srcViewController = sender.sourceViewController;
    srcViewController.UserSettings = nil;
    srcViewController.DefaultSettings = nil;
    srcViewController = nil;
    
//    settings = [srcViewController.UserSettings copy];
    NSLog(@"Cancel Button Pressed");
    //[self performSegueWithIdentifier:@"cancelTo" sender:self];
}

-(IBAction)backPressed:(UIStoryboardSegue *)segue
{

    [[[LocalManager sharedInstance] thisURLCache] setDiskCapacity:0];
    [[[LocalManager sharedInstance] thisURLCache] setMemoryCapacity:0];

    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"Back Button Pressed");
    // Back Button on MessageView was pressed
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MessageView"])
    {
        NSInteger index = [self.tableView indexPathForSelectedRow].row;
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        MessageViewController *msgvc = segue.destinationViewController;
        msgvc.HTMLMessage = [[MailManager sharedInstance] getHTMLMessageBodyByIndex:index];
    }
    if ([segue.identifier isEqualToString:@"SettingsView"])
    {
        //SettingsViewController *destViewController = segue.destinationViewController;
        //destViewController.settingsArr = [settingsArr copy];
        //destViewController.delegate = self;
    }
}

#pragma mark - Bar Button presses




- (IBAction)refreshItems:(UIBarButtonItem *)sender
{
    NSLog(@"Refresh Button Pressed");
    [[MailManager sharedInstance] requestMessages:NUMMSGS];
    // replace the current "Save" button with the loading spinner animation
    self.RefreshButton.enabled = NO;
    self.RefreshButton.customView = spinner;
    [spinner startAnimating];
    
    // Disable all controls
    self.navigationItem.leftBarButtonItem.enabled = NO;
//        msgSubjects = [NSArray arrayWithArray:[[MailManager sharedInstance] getSubjects:NUMMSGS]];
//        msgDates = [NSArray arrayWithArray:[[MailManager sharedInstance] getDates:NUMMSGS]];
//    
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Response"
//                                                        message:@"Cannot get mail. Please try again later."
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        [alert setTintColor:[UIColor redColor]];
//        [alert show];
//    }
}

//- (IBAction)goToSettings:(UIBarButtonItem *)sender
//{
//    [self performSegueWithIdentifier:@"SettingsView" sender:self];
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
