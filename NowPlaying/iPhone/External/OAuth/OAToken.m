//
//  OAToken.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Back-ported to obj-c 1.x by George Fletcher


#import "OAToken.h"

@interface OAToken()
@property (copy) NSString *key;
@property (copy) NSString *secret;
@end


@implementation OAToken

@synthesize key;
@synthesize secret;

- (void) dealloc {
    self.key = nil;
    self.secret = nil;
    
    [super dealloc];
}


- (id) init {
    if (self = [super init]) {
        self.key = @"";
        self.secret = @"";
    }
    
    return self;
}


- (id) initWithKey:(NSString*) aKey
            secret:(NSString*) aSecret {
    if (self = [super init]) {
        self.key = aKey;
        self.secret = aSecret;
    }
    
    return self;
}


- (id) initWithHTTPResponseBody:(NSString *)body {
    if (self = [super init]) {
        NSArray *pairs = [body componentsSeparatedByString:@"&"];
        
        // Converted for loop to be Obj-c 1.x compliant
        int count, i;
        count = [pairs count];
        for (i = 0; i < count; i++) {
            NSString *pair = [pairs objectAtIndex:i];
            NSArray  *elements = [pair componentsSeparatedByString:@"="];
            if ( [[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
                [self setKey:[elements objectAtIndex:1]];
            } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
                [self setSecret:[elements objectAtIndex:1]];
            }
        }
    }
    
    return self;
}


+ (OAToken*) tokenWithKey:(NSString*) key secret:(NSString*) secret {
    return [[[OAToken alloc] initWithKey:key secret:secret] autorelease];
}


+ (OAToken*) tokenWithHTTPResponseBody:(NSString*) body {
    return [[[OAToken alloc] initWithHTTPResponseBody:body] autorelease];
}

/*
- (id)initWithKeychainUsingAppName:(NSString *)name serviceProviderName:(NSString *)provider {
    [super init];
    SecKeychainItemRef item;
    NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
    OSStatus status = SecKeychainFindGenericPassword(NULL,
                                                     strlen([serviceName UTF8String]),
                                                     [serviceName UTF8String],
                                                     0,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     &item);
    if (status != noErr) {
        return nil;
    }
    
    // from Advanced Mac OS X Programming, ch. 16
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    status = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&password);
    
    if (status == noErr) {
        [self setKey:[NSString stringWithCString:list.attr[0].data
                                          length:list.attr[0].length]];
        if (password != NULL) {
            char passwordBuffer[1024];
            
            if (length > 1023) {
                length = 1023;
            }
            strncpy(passwordBuffer, password, length);
            
            passwordBuffer[length] = '\0';
            [self setSecret:[NSString stringWithCString:passwordBuffer]];
        }
        
        SecKeychainItemFreeContent(&list, password);
        
    } else {
        // TODO find out why this always works in i386 and always fails on ppc
        NSLog(@"Error from SecKeychainItemCopyContent: %d", status);
        return nil;
    }
    
    // NSMakeCollectable not supported in Obj-1.x
    CFMakeCollectable(item);
    
    return self;
}
*/

//- (int)storeInDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider {
//    return [self storeInKeychain:NULL appName:name serviceProviderName:provider];
//}

/*
- (int)storeInKeychain:(SecKeychainRef)keychain appName:(NSString *)name serviceProviderName:(NSString *)provider {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:kSecClassGenericPassword forKey:kSecClass];
    
    
    UInt32 serviceNameLength, const char *serviceName, UInt32 accountNameLength, const char *accountName, UInt32 passwordLength, const void *passwordData,
    
    OSStatus status = SecItemAdd(
    
    OSStatus status = SecKeychainAddGenericPassword(keychain,                                     
                                                    [name length] + [provider length] + 9, 
                                                    [[NSString stringWithFormat:@"%@::OAuth::%@", name, provider] UTF8String],
                                                    [[self key] length],                        
                                                    [[self key] UTF8String],
                                                    [[self secret] length],
                                                    [[self secret] UTF8String],
                                                    NULL
                                                    );
    return status;
}

*/
@end