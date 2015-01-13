//
//  MessageViewController.h
//  GenericMail
//
//  Created by Eric Lam on 4/7/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Primary class that implements the UIWebViewDelegate
 Specifically represents the message to be displayed based on the segue from MailView
 */
@interface MessageViewController : UIViewController <UIWebViewDelegate>

/** String containing the raw HTML code for the mail message */
@property (nonatomic, strong) NSString *HTMLMessage;

/** WebView view that will render the HTML code */
@property (nonatomic, weak) IBOutlet UIWebView *webView;




@end
