//
//  ContactBusiness.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactBusiness.h"
#import "ContactAdapter.h"
#import "Contact.h"

#import <Contacts/Contacts.h>

@interface ContactBusiness ()

@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation ContactBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        _contacts = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("contactBusinessSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)loadContactsWithCompletion:(void (^)(NSArray<Contact *> * contacts, NSError * error))completionHandle {
    if (!completionHandle)
        return;
    
    [[ContactAdaper instance] fetchContactsWithCompletion:^(NSArray<Contact *> *contacts, NSError *error) {
        if (!completionHandle)
            return;
        
        if (!error) {
            completionHandle(contacts, nil);
        } else {
            completionHandle(nil, error);
        }
    }];
}

- (void)loadContactImageByID:(NSString *)contactID
                  completion:(void (^)(UIImage *image, NSError * error))completionHandle {
    if (!completionHandle)
        return;
    
    [[ContactAdaper instance] fetchContactImageDataByID:contactID
                                             completion:^(UIImage *image, NSError *error) {
        if (!completionHandle)
            return;
        
        if (!error) {
            completionHandle(image, nil);
        } else {
            completionHandle(nil, error);
        }
    }];
}

- (ContactAuthorState)permissionStateToAccessContactData {
    CNAuthorizationStatus authorStatus = [[ContactAdaper instance] getAccessContactAuthorizationStatus];
    if (authorStatus == CNAuthorizationStatusAuthorized) {
        return ContactAuthorStateAuthorized;
    } else if (authorStatus == CNAuthorizationStatusDenied) {
        return ContactAuthorStateDenied;
    } else if (authorStatus == CNAuthorizationStatusNotDetermined) {
        return ContactAuthorStateNotDetermined;
    } else {
        return ContactAuthorStateDefault;
    }
}

- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted))completionHandle {
    if (!completionHandle)
        return;
    
    [[ContactAdaper instance] requestAccessWithCompletionHandle:^(BOOL granted) {
        completionHandle(granted);
    }];
}

- (NSMutableArray<NSMutableArray *> *)sortedByAlphabetSectionsArrayFromContacts:(NSMutableArray<Contact *> *)contacts {
    if (!contacts)
        return nil;
    
    NSMutableArray<NSMutableArray *> *sectionsArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
        sectionsArray[i] = [[NSMutableArray alloc] init];
    }
    
    [self fitContactsData:contacts toSectionArray:sectionsArray];
    
    return sectionsArray;
}

- (void)fitContactsData:(NSMutableArray<Contact *> *)contacts
         toSectionArray:(NSMutableArray<NSMutableArray *> *)sections {
#if DEBUG
    assert(sections);
    assert(sections.count == ALPHABET_SECTIONS_NUMBER);
#endif
    
    if (!contacts || !sections)
        return;
    if (contacts && contacts.count == 0)
        return;
    if (sections && sections.count == 0)
        return;
    
    for (int i = 0; i < sections.count; i++) {
        [sections[i] removeAllObjects];
    }
    
    for (int i = 0; i < contacts.count; i++) {
        int index = [contacts[i] getSectionIndex];
    
        if (index >= 0 && index < ALPHABET_SECTIONS_NUMBER - 1) {
            [sections[index] addObject:contacts[i]];
        } else {
            [sections[ALPHABET_SECTIONS_NUMBER - 1] addObject:contacts[i]];
        }
    }
}

- (void)resigterContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate {
#if DEBUG
    assert(delegate);
#endif
    
    if (!delegate)
        return;
    
    [[ContactAdaper instance] resigterContactDidChangedDelegate:delegate];
}

- (void)removeContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate {
#if DEBUG
    assert(delegate);
#endif
    
    if (!delegate)
        return;
    
    [[ContactAdaper instance] removeContactDidChangedDelegate:delegate];
}

- (NSArray<Contact *> *)filterContacts:(NSArray<Contact *> *)contacts
                        bySearchString:(NSString *)searchString {
    if (!searchString)
        return contacts;
    else if (searchString.length == 0)
        return contacts;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchString];
    NSArray *filteredContacts = [contacts filteredArrayUsingPredicate:predicate];
    
    return filteredContacts;
}

- (NSArray<Contact *> *)sortedContacts:(NSArray<Contact *> *)contacts
                             ascending:(BOOL)ascending {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self.name"
                                                               ascending:ascending];
    return [contacts sortedArrayUsingDescriptors:@[descriptor]];
}

@end
