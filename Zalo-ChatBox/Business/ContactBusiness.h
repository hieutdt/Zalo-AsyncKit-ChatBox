//
//  ContactBusiness.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "Contact.h"
#import "AppConsts.h"

#import "ContactDidChangedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactBusiness : NSObject

- (ContactAuthorState)permissionStateToAccessContactData;

- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted))completionHandle;

- (void)loadContactsWithCompletion:(void (^)(NSArray<Contact *> *contacts, NSError *error))completionHandle;

- (void)loadContactImageByID:(NSString*)contactID
                  completion:(void (^)(UIImage *image, NSError *error))completionHandle;

- (NSMutableArray<NSMutableArray *> *)sortedByAlphabetSectionsArrayFromContacts:(NSMutableArray<Contact *> *)contacts;

- (void)fitContactsData:(NSMutableArray<Contact *> *)contacts
         toSectionArray:(NSMutableArray<NSMutableArray *> *)sections;

- (void)resigterContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate;

- (void)removeContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate;

- (NSArray<Contact *> *)filterContacts:(NSArray<Contact *> *)contacts
                        bySearchString:(NSString *)searchString;

- (NSArray<Contact *> *)sortedContacts:(NSArray<Contact *> *)contacts
                             ascending:(BOOL)ascending;

@end

NS_ASSUME_NONNULL_END
