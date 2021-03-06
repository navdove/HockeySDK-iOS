//
//  HockeySDKPrivateTests.m
//  HockeySDK
//
//  Created by Andreas Linde on 25.09.13.
//
//

#import <XCTest/XCTest.h>

#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "HockeySDK.h"
#import "BITHockeyHelper.h"
#import "BITKeychainUtils.h"


@interface BITHockeyHelperTests : XCTestCase

@end

@implementation BITHockeyHelperTests


- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown {
  // Tear-down code here.
  [super tearDown];
}

- (void)testURLEncodedString {
  assertThat(bit_URLEncodedString(@"123 {Test, b0c10b1}"), equalTo(@"123%20%7BTest%2C%20b0c10b1%7D"));
  assertThat(bit_URLEncodedString(@"7902c5a8ecee4b17a758880253090569"), equalTo(@"7902c5a8ecee4b17a758880253090569"));
  assertThat(bit_URLEncodedString(@"udid"), equalTo(@"udid"));
  assertThat(bit_URLEncodedString(@"983024C8-A861-4649-89BC-4D92896269A4"), equalTo(@"983024C8-A861-4649-89BC-4D92896269A4"));
  assertThat(bit_URLEncodedString(@"16"), equalTo(@"16"));
  assertThat(bit_URLEncodedString(@"9.0"), equalTo(@"9.0"));
  assertThat(bit_URLEncodedString(@"x86_64"), equalTo(@"x86_64"));
  assertThat(bit_URLEncodedString(@"en"), equalTo(@"en"));
  assertThat(bit_URLEncodedString(@"09/10/2015"), equalTo(@"09%2F10%2F2015"));
  assertThat(bit_URLEncodedString(@"https://sdk.hockeyapp.net/api/2/apps/fd51a3647d651add2171dd59d3b6e5ec/app_versions/21?format=plist&udid=82610469-C064-412D-AEAC-F453EB506726"), equalTo(@"https%3A%2F%2Fsdk.hockeyapp.net%2Fapi%2F2%2Fapps%2Ffd51a3647d651add2171dd59d3b6e5ec%2Fapp_versions%2F21%3Fformat%3Dplist%26udid%3D82610469-C064-412D-AEAC-F453EB506726"));
  assertThat(bit_URLEncodedString(@"net.hockeyapp.sdk"), equalTo(@"net.hockeyapp.sdk"));
}

- (void)testValidateEmail {
  BOOL result = NO;
  
  // valid email
  result = bit_validateEmail(@"mail@test.com");
  assertThatBool(result, isTrue());
  
  // invalid emails
  
  result = bit_validateEmail(@"mail@test");
  assertThatBool(result, isFalse());

  result = bit_validateEmail(@"mail@.com");
  assertThatBool(result, isFalse());

  result = bit_validateEmail(@"mail.com");
  assertThatBool(result, isFalse());

}

- (void)testAppName {
  NSString *resultString = bit_appName(@"Placeholder");
  assertThatBool([resultString isEqualToString:@"Placeholder"], isTrue());
}

- (void)testUUIDPreiOS6 {
  NSString *resultString = bit_UUIDPreiOS6();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], equalToInteger(36));
}

- (void)testUUID {
  NSString *resultString = bit_UUID();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], equalToInteger(36));
}

- (void)testAppAnonID {
  // clean keychain cache
  NSError *error = NULL;
  [BITKeychainUtils deleteItemForUsername:@"appAnonID"
                           andServiceName:bit_keychainHockeySDKServiceName()
                                    error:&error];
  
  NSString *resultString = bit_appAnonID(NO);
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], equalToInteger(36));
}

- (void)testValidAppIconFilename {
  NSString *resultString = nil;
  NSBundle *mockBundle = mock([NSBundle class]);
  NSBundle *resourceBundle = [NSBundle bundleForClass:self.class];
  NSString *validIconPath = @"AppIcon";
  NSString *validIconPath2x = @"AppIcon@2x";
  
  // No valid icons defined at all
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFiles"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons~ipad"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFile"]) willReturn:@"invalidFilename.png"];
  
  resultString = bit_validAppIconFilename(mockBundle, resourceBundle);
  assertThat(resultString, nilValue());
  
  // CFBundleIconFiles contains valid filenames
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFiles"]) willReturn:@[validIconPath, validIconPath2x]];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons~ipad"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFile"]) willReturn:nil];

  resultString = bit_validAppIconFilename(mockBundle, resourceBundle);
  assertThat(resultString, notNilValue());
  
  // CFBundleIcons contains valid dictionary filenames
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFiles"]) willReturn:@[@"invalidFilename.png"]];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons"]) willReturn:@{@"CFBundlePrimaryIcon":@{@"CFBundleIconFiles":@[validIconPath, validIconPath2x]}}];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons~ipad"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFile"]) willReturn:nil];

  // CFBundleIcons contains valid ipad dictionary and valid default dictionary filenames
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFiles"]) willReturn:@[@"invalidFilename.png"]];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons"]) willReturn:@{@"CFBundlePrimaryIcon":@{@"CFBundleIconFiles":@[validIconPath, validIconPath2x]}}];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons~ipad"]) willReturn:@{@"CFBundlePrimaryIcon":@{@"CFBundleIconFiles":@[validIconPath, validIconPath2x]}}];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFile"]) willReturn:nil];

  resultString = bit_validAppIconFilename(mockBundle, resourceBundle);
  assertThat(resultString, notNilValue());

  // CFBundleIcons contains valid filenames
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFiles"]) willReturn:@[@"invalidFilename.png"]];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons"]) willReturn:@[validIconPath, validIconPath2x]];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons~ipad"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFile"]) willReturn:nil];

  resultString = bit_validAppIconFilename(mockBundle, resourceBundle);
  assertThat(resultString, notNilValue());

  // CFBundleIcon contains valid filename
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFiles"]) willReturn:@[@"invalidFilename.png"]];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIcons~ipad"]) willReturn:nil];
  [given([mockBundle objectForInfoDictionaryKey:@"CFBundleIconFile"]) willReturn:validIconPath];
  
  resultString = bit_validAppIconFilename(mockBundle, resourceBundle);
  assertThat(resultString, notNilValue());
}

- (void)testDevicePlattform {
  NSString *resultString = bit_devicePlatform();
  assertThat(resultString, notNilValue());
}

- (void)testDeviceModel {
  NSString *resultString = bit_devicePlatform();
  assertThat(resultString, notNilValue());
}

- (void)testOsVersion {
  NSString *resultString = bit_osVersionBuild();
  assertThat(resultString, notNilValue());
  assertThatFloat([resultString floatValue], greaterThan(@(0.0)));
}

- (void)testOsName {
  NSString *resultString = bit_osName();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], greaterThan(@(0)));
}

- (void)testDeviceType {
  NSString *resultString = bit_deviceType();
  assertThat(resultString, notNilValue());
  NSArray *typesArray = @[@"Phone", @"Tablet", @"Unknown"];
  assertThat(typesArray, hasItem(resultString));
}

- (void)testSdkVersion {
  NSString *resultString = bit_sdkVersion();
  assertThat(resultString, notNilValue());
  assertThatInteger([resultString length], greaterThan(@(0)));
}

- (void)testUtcDateString{
  NSDate *testDate = [NSDate dateWithTimeIntervalSince1970:0];
  NSString *utcDateString = bit_utcDateString(testDate);
  
  assertThat(utcDateString, equalTo(@"1970-01-01T00:00:00.000Z"));
}

#ifndef CI
- (void)testUtcDateStringPerformane {
  [self measureBlock:^{
    for (int i = 0; i < 100; i++) {
      NSDate *testDate = [NSDate dateWithTimeIntervalSince1970:0];
      bit_utcDateString(testDate);
    }
  }];
}
#endif

- (void)testConvertAppIdToGuidWorks {
	NSString *myAppID = @"    ca2aba1482cb9458a67b917930b202c8      ";
	NSString *expected = @"ca2aba14-82cb-9458-a67b-917930b202c8";
	
	// Test
	NSString *result = bit_appIdentifierToGuid(myAppID);
	
	// Verify
	assertThat(result, equalTo(expected));
}

- (void)testConvertInvalidAppIdToGuidReturnsNil {
	NSString *myAppID = @"ca2aba1482cb9458a6";
	
	// Test
	NSString *result = bit_appIdentifierToGuid(myAppID);
	
	// Verify
  assertThat(result, nilValue());
}

@end
