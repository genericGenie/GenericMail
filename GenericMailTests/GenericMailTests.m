//
//  GenericMailTests.m
//  GenericMailTests
//
//  Created by Eric Lam on 4/6/14.
//  Copyright (c) 2014 Eric Lam. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SettingsViewController.h"
#import "MailViewController.h"
#import "HostSettingsModel.h"

@interface GenericMailTests : XCTestCase

@property (nonatomic, strong) MailViewController *mv;
@property (nonatomic, strong) SettingsViewController *settingsVC;

@end

@implementation GenericMailTests

- (void)setUp
{
    [super setUp];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.mv = [storyboard instantiateViewControllerWithIdentifier:@"MailView"];
    [self.mv performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
//    [self.mv viewDidLoad];
    self.settingsVC = [[SettingsViewController alloc] init];

}

- (void)tearDown
{
    self.mv = nil;
    self.settingsVC = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStoryBoardControllers
{
    NSLog(@"Verify the Main_iPhone storyboard was loaded");
    XCTAssertNotNil(self.mv, @"Storyboard should exist");
    NSLog(@"Verify the SettingsViewController was loaded");
    XCTAssertNotNil(self.settingsVC, @"SettingsViewController should exists");
}

- (void)testHostSettingsModelDefaults
{
    NSDictionary *dict = [[HostSettingsModel sharedInstance] getDefaultSettingsByIndexCopy:0];
    NSLog(@"Verify the Default Login credentials are loaded");
    XCTAssertEqualObjects(dict[@"hostname"], @"imap.gmail.com", @"Hostname should equal defaults");
    XCTAssertEqualObjects(dict[@"port"], @"993", @"Port# should equal defaults");
    XCTAssertEqualObjects(dict[@"username"], @"google@gmail.com", @"username should equal defaults");
    XCTAssertEqualObjects(dict[@"password"], @"somePassword", @"password should equal defaults");
}

- (void)testHostSettingsModelLabels
{
    NSArray *labels = @[@"hostname",@"port",@"username",@"password"];
    NSArray *arr = [[[HostSettingsModel sharedInstance] getDefaultSettingsKeys] copy];
    NSLog(@"Expected labels");
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger x, BOOL *stop) {
        NSLog(@"arr[%lu] == %@ and labels[%lu] == %@", (unsigned long)x, arr[x], (unsigned long)x, labels[x]);
        XCTAssertEqualObjects(arr[x], labels[x], @"Array[%lu] should be \"%@\"", (unsigned long)x, labels[x]);
    }];
}



@end
