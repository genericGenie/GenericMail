//
//  MessageViewController.m
//  GenericMail
//
//  Created by Eric Lam on 4/7/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import "MessageViewController.h"
#import "LocalManager.h"



@interface MessageViewController ()
{
    UIWebView *webview;
}

@end

@implementation MessageViewController



- (void)viewDidLoad
{
    // This 3 line chunk of code was originally designed to release the large amount of memory allocated by UIWebView.
    // What UIWebView fails to do is release this memory once the UIWebView is properly deallocated.  This is a known issue, that Apple
    // purposely fails to address because they don't want another company creating a browser that rivals Safari.
    // Google Chrome probably uses ContainerViews to address this issue, but even they are not immune to the memory problem.
    // The solution is to only have a single UIWebView, any tabs are cached in memory. Unfortunately this makes reloading a previous tab take longer.
    [[[LocalManager sharedInstance] thisURLCache] removeAllCachedResponses];
    [[[LocalManager sharedInstance] thisURLCache] setDiskCapacity:0];
    [[[LocalManager sharedInstance] thisURLCache] setMemoryCapacity:0];
    [super viewDidLoad];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // this is a junk UIWebView used to shrink the loaded UIWebView taking up less memory
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    webview.scalesPageToFit = NO;
    webview.delegate = nil;

    [self.webView loadHTMLString:self.HTMLMessage baseURL:nil];

//    self.MessageBody.text = [self.Messages description];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.HTMLMessage = nil;
    NSLog(@"loading nothing");
    [self.webView loadHTMLString:@"" baseURL:nil];

    [[[LocalManager sharedInstance] thisURLCache] removeAllCachedResponses];
    [[[LocalManager sharedInstance] thisURLCache] setDiskCapacity:0];
    [[[LocalManager sharedInstance] thisURLCache] setMemoryCapacity:0];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    /// Primarily used for debugging with Instruments
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self)
    {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"Loaded was requested");
    if ( navigationType == UIWebViewNavigationTypeLinkClicked )
    {
        /// Load into Safari which we don't want, otherwise uiautomation will have no navigation control
        ///[[[LocalManager sharedInstance] thisApp] openURL:[request URL]];

        NSURL *url = request.URL;
        NSString *urlString = url.absoluteString;
        NSLog(@"%@", urlString);
        [self.webView loadRequest:request];

        return NO;
    }
    return YES;
    
}

#pragma mark - Cleanup

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[[LocalManager sharedInstance] thisURLCache] removeAllCachedResponses];
    [[[LocalManager sharedInstance] thisURLCache] setDiskCapacity:0];
    [[[LocalManager sharedInstance] thisURLCache] setMemoryCapacity:0];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /// WebKitCacheModelPreferenceKey is set to 1 when loading
    /// set to zero to stop loading
    [[[LocalManager sharedInstance] thisDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}



- (void)dealloc
{
    // shrink the memory
    self.webView = webview;
    self.webView.delegate = nil;
    [self.webView stopLoading];
    if (![NSThread isMainThread])
    {
        [self.webView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    }
    self.webView = nil;
    self.HTMLMessage = nil;
    webview = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // [self.msgWebView reload];
}



#pragma mark - Web Browser navigation buttons

// None of the following have been tested or fully implemented.  They are just here for cosmetic purposes
- (IBAction)pressBrowserBackButton:(UIBarButtonItem *)sender
{
    [self.webView goBack];
}

- (IBAction)pressBrowserForwardButton:(UIBarButtonItem *)sender
{
    [self.webView goForward];
}


- (IBAction)pressBrowserRefreshButton:(id)sender
{
    [self.webView reload];
}

- (IBAction)pressBrowserStopButton:(UIBarButtonItem *)sender
{
    [self.webView stopLoading];
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
