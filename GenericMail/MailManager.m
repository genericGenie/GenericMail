//
//  MailManager.m
//  GenericMail
//
//  Created by Eric Lam on 4/17/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import "MailManager.h"
#import "HostSettingsModel.h"

@implementation MailManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        if ([self isHostSettings])
        {
            [self prepareMailSettings];
            _msgHeaderArr = [NSMutableArray array];
            _msgBodyArr = [NSMutableArray array];
            _fetchUIDs = [NSMutableArray array];
            _tempArray = [NSMutableArray array];
            isSettingsValid = NO;
            listItemNumber = 0;
        }
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t lockToken;
    static MailManager *sharedInstance;
    dispatch_once(&lockToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (BOOL)isHostSettings
{
    if (listItemNumber < 0)
        listItemNumber = 0;
    _hostSettings = [[HostSettingsModel sharedInstance] getUserSettingsByIndexCopy:listItemNumber];
    if (!_hostSettings)
        return NO;
    return YES;
}

- (void)prepareMailSettings
{
    if (!_MailCoreSession)
        _MailCoreSession = [[MCOIMAPSession alloc] init];
    [self isHostSettings];
    [_MailCoreSession setHostname:(NSString *)_hostSettings[@"hostname"]];
    [_MailCoreSession setPort:[_hostSettings[@"port"] intValue]];
    [_MailCoreSession setUsername:(NSString *)_hostSettings[@"username"]];
    [_MailCoreSession setPassword:(NSString *)_hostSettings[@"password"]];
    [_MailCoreSession setConnectionType:MCOConnectionTypeTLS];
}

- (NSDictionary *)getSettingsCopy
{
    if (![self isHostSettings])
        return nil;
    return _hostSettings;
}

- (NSArray *)getDates:(NSInteger)numberOfDates
{
    _tempArray = [NSMutableArray arrayWithCapacity:[_msgHeaderArr count]];
    [_msgHeaderArr enumerateObjectsUsingBlock:^(MCOMessageParser* obj, NSUInteger idx, BOOL *stop) {
        if (obj.header.receivedDate == NULL)
            [_tempArray addObject:@""];
        else
            [_tempArray addObject:obj.header.receivedDate];
        //        NSLog(@"Fetched subject = %@", obj.header.subject);
        //        NSLog(@"Fetched msgID = %u", [obj uid]);
        //        NSLog(@"Fetched DateTime = %@", obj.header.receivedDate);
    }];
    return _tempArray;
}

- (NSArray *)getSubjects:(NSInteger)numberOfSubjects
{
    _tempArray = [NSMutableArray arrayWithCapacity:[_msgHeaderArr count]];
    [_msgHeaderArr enumerateObjectsUsingBlock:^(MCOMessageParser* obj, NSUInteger idx, BOOL *stop) {
        if (obj.header.subject == NULL)
            [_tempArray addObject:@""];
        else
            [_tempArray addObject:obj.header.subject];
//        NSLog(@"Fetched subject = %@", obj.header.subject);
//        NSLog(@"Fetched msgID = %u", [obj uid]);
//        NSLog(@"Fetched DateTime = %@", obj.header.receivedDate);
    }];
    return _tempArray;
}

- (BOOL)isValidSettings
{
    return isSettingsValid;
}

- (void)checkSettingsRequest
{
    [self prepareMailSettings];
    isSettingsValid = NO;
    // Get the Headers debug code
//    MCOIMAPSession *session = [[MCOIMAPSession alloc] init];
//    session.hostname = @"imap.gmail.com";
//    session.port = 993;
//    session.username = @"someone@gmail.com";
//    session.password = @"password";
//    session.connectionType = MCOConnectionTypeTLS;
    MCOIndexSet *uidSet = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    MCOIMAPFetchMessagesOperation *fetchOp =
    [_MailCoreSession fetchMessagesByUIDOperationWithFolder:@"[GMail]/All Mail"
                                                requestKind:MCOIMAPMessagesRequestKindHeaders
                                                       uids:uidSet];

    [fetchOp start:^(NSError *err, NSArray *msgs, MCOIndexSet *vanished)
    {
        if (err != NULL)
        {
            NSArray *reverseArray = [[msgs reverseObjectEnumerator] allObjects];
            [reverseArray enumerateObjectsUsingBlock:^(MCOIMAPMessage* obj, NSUInteger idx, BOOL *stop)
            {
                NSLog(@"Fetched subject = %@", obj.header.subject);
                NSLog(@"Fetched msgID = %u", [obj uid]);
                NSLog(@"Fetched DateTime = %@", obj.header.receivedDate);
            }];
            _msgHeaderArr = [reverseArray mutableCopy];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Request Successful" object:nil];
        }
        else
        {
            isSettingsValid = NO;
            [_msgHeaderArr subarrayWithRange:NSMakeRange(0, 1)];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Request Failed" object:nil];
        }
        MCOIMAPOperation *op = [_MailCoreSession disconnectOperation];
        [op start:^(NSError *error)
        {
            NSLog(@"Disconnected");
            NSLog(@"Errors = %@", error);
        }];
    }];
}

- (NSString *)getHTMLMessageBodyByIndex:(NSInteger)index
{
    NSInteger i = [_msgBodyArr count];
    if (i >= index && i != 0 )
    {
        NSLog(@"get copy of HTML body");
        return [NSString stringWithFormat:@"%@", _msgBodyArr[index]];
    }
    return @"Loading...";
}

- (void)setAccount:(NSInteger)listItem
{
    listItemNumber = listItem;
}

- (void)requestMessages:(NSInteger)numMsgs
{
    __block BOOL isCompleted = YES;

    // All this code will get all the messages in the INBOX except for the file attachments
    // Internally, MailCore is ran asynchronously. It already uses NSOperationQueue and dispatch_async(). So no need to add redundant code.
    [self prepareMailSettings];

    _msgBodyArr = [NSMutableArray arrayWithCapacity:numMsgs];
    _msgHeaderArr = [NSMutableArray arrayWithCapacity:numMsgs];
    _fetchUIDs = [NSMutableArray arrayWithCapacity:numMsgs];
    NSString *folder = @"INBOX";
    MCOIMAPFolderInfoOperation *folderInfo = [_MailCoreSession folderInfoOperation:folder];
    //__block __strong NSMutableArray *toFetchUIDs = [NSMutableArray array];

    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        NSInteger numberOfMessages = numMsgs; numberOfMessages -= 1;
        MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages)];
        MCOIMAPFetchMessagesOperation *fetchOperation = [_MailCoreSession fetchMessagesByNumberOperationWithFolder:folder requestKind:MCOIMAPMessagesRequestKindUid numbers:numbers];
        
        NSLog(@"Errors = %@", error);
        if (error != NULL)
        {
            isCompleted = NO;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"Request Failed" object:self];
        }
        [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
            NSArray *reverseArray = [[messages reverseObjectEnumerator] allObjects];
            for (MCOIMAPMessage * message in reverseArray)
            {
                MCOIMAPFetchContentOperation *operation = [_MailCoreSession fetchMessageByUIDOperationWithFolder:folder uid:[message uid]];
                [operation start:^(NSError *error, NSData *data) {
                    if (error != NULL)
                    {
                        isCompleted = NO;
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Request Failed" object:self];
                    }
                    MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
                    //// HTML source code with the Header attached (From, To, Subject, Date)
                    NSString *msgHTMLBody = [messageParser htmlRenderingWithDelegate:nil];
                    //// HTML source code having removed the header
//                    NSString *msgHTMLBody = [messageParser htmlBodyRendering];
                    
//                    NSString *msgPlainTextBody = [messageParser plainTextBodyRendering];
                    
                    if (!msgHTMLBody)
                    {
                        NSLog(@"****************** Error, msgHTMLBody is nil ******************");
                        NSLog(@"Errors = %@", error);
                    }
                    else
                    {
                        // Save the Headers (dateTime, subject, uniqueMessageID)
                        [_msgHeaderArr addObject:messageParser];
                        // Save the Message Body
                        [_msgBodyArr addObject:msgHTMLBody];
                        // Save the unique message identifiers
                        [_fetchUIDs addObject:[NSNumber numberWithInteger:[message uid]]];
                        NSLog(@"////////   Header Subject = %@", messageParser.header.subject);
                        NSLog(@"////////   UID = %u ///////////", [message uid]);
                        NSLog(@"////////   Message Body = %@", msgHTMLBody);
                    }
                }];
                
            }
            // It is possible to keep the session open to send, delete, flag, and organize mail files,
            // but since we only care about fetching messages, then the "_MailCoreSession" object is not kept open
            MCOIMAPOperation *op = [_MailCoreSession disconnectOperation];
            [op start:^(NSError *error) {
//                if (error != NULL)
//                    isCompleted = NO;
                NSLog(@"Session Disconnected");
                NSLog(@"Errors = %@", error);
                [_MailCoreSession cancelAllOperations];
                _MailCoreSession = nil;
                if (isCompleted)
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Request Successful" object:self];
                else
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Request Failed" object:self];
            }];
        }];
        
    }];
}
                   


@end








