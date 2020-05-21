//
//  ContactAdapter.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "Contact.h"
#import "ContactDidChangedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactAdaper : NSObject

+ (instancetype)instance;

- (CNAuthorizationStatus)getAccessContactAuthorizationStatus;

- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted))completionHandle;

- (void)fetchContactsWithCompletion:(void (^)(NSArray<Contact *> *contacts, NSError * error))completionHandler;

- (void)fetchContactImageDataByID:(NSString*)contactID
                       completion:(void (^)(UIImage *image, NSError *error))completionHandle;

- (void)fetchContactsByPredicate:(NSPredicate *)predicate
                  withCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle;

- (void)resigterContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate;

- (void)removeContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
