//
//  ContactAdapter.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactAdapter.h"
#import "StringHelper.h"
#import "AppConsts.h"

#import <Contacts/Contacts.h>

@interface ContactAdaper()

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@property (nonatomic, strong) NSMutableArray<id<ContactDidChangedDelegate>> *contactDidChangedDelegates;
@property (nonatomic, strong) NSMutableArray<NSString *> *keysToFetch;

@property (nonatomic, strong) NSMutableArray<void (^)(NSArray *contacts, NSError *error)> *completionHandlers;

@end

@implementation ContactAdaper

- (instancetype)init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("contactAdaperSerialQueue", DISPATCH_QUEUE_SERIAL);
        _concurrentQueue = dispatch_queue_create("contactAdapterConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        _contactDidChangedDelegates = [[NSMutableArray alloc] init];
        
        _keysToFetch = [NSMutableArray arrayWithArray: @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]];
        
        _completionHandlers = [[NSMutableArray alloc] init];
        
        // Add Contact changes Observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contactsDidChange) name:CNContactStoreDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)instance {
    static id sharedInstance = nil;
    
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[ContactAdaper alloc] init];
        });
    }
    
    return sharedInstance;
}

#pragma mark - FetchMethods

- (void)fetchContactsWithCompletion:(void (^)(NSArray<Contact *> *contacts, NSError * error))completionHandler {
    if (!completionHandler)
        return;
    
    @synchronized (self) {
        [self.completionHandlers addObject:completionHandler];
    }
    
    dispatch_async(self.serialQueue, ^{
        if (self.completionHandlers.count == 0) {
            return;
        }
        
        NSMutableArray<CNContact*> *CNContacts = [[NSMutableArray alloc] init];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.keysToFetch];
        
        @try {
            [contactStore enumerateContactsWithFetchRequest:request
                                                      error:nil
                                                 usingBlock:^(CNContact *contact, BOOL *stop) {
                [CNContacts addObject:contact];
            }];
            
            NSArray<Contact *> *contacts = [self getContactModelsFromCNContacts:CNContacts];
            [self forwardAllCompletionHandlers:contacts error:nil];
            
        } @catch (NSException *e) {
            NSLog(@"ContactAdapter: Unable to fetch contacts: %@", e);
            
            NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter"
                                                        code:200
                                                    userInfo:@{@"Lấy dữ liệu danh bạ thất bại" : NSLocalizedDescriptionKey}];
            [self forwardAllCompletionHandlers:nil error:error];
        }
    });
}

- (void)refetchContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle {
    if (!completionHandle)
        return;
    
    dispatch_async(self.serialQueue, ^{
        NSMutableArray<CNContact*> *CNContacts = [[NSMutableArray alloc] init];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.keysToFetch];
        
        @try {
            [contactStore enumerateContactsWithFetchRequest:request
                                                      error:nil
                                                 usingBlock:^(CNContact *contact, BOOL *stop) {
                [CNContacts addObject:contact];
            }];
            
            NSArray<Contact *> *contacts = [self getContactModelsFromCNContacts:CNContacts];
            [self forwardAllCompletionHandlers:contacts error:nil];
            
        } @catch (NSException *e) {
            NSLog(@"ContactAdapter: Unable to fetch contacts: %@", e);
            
            NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter"
                                                        code:200
                                                    userInfo:@{@"Lấy dữ liệu danh bạ thất bại" : NSLocalizedDescriptionKey}];
            
            [self forwardAllCompletionHandlers:nil error:error];
        }
    });
}

- (void)fetchContactImageDataByID:(NSString *)contactID
                       completion:(void (^)(UIImage *image, NSError *error))completionHandle {
    if (!completionHandle)
        return;
    
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[contactID]];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter"
                                                code:200
                                            userInfo:@{@"Tải hình ảnh thất bại.": NSLocalizedDescriptionKey}];
    
    // Fetch multiple images concurrently
    dispatch_async(self.concurrentQueue, ^{
        @try {
            NSArray<CNContact *> *contacts = [contactStore unifiedContactsMatchingPredicate:predicate
                                                                                keysToFetch:@[CNContactThumbnailImageDataKey]
                                                                                      error:nil];
            
            if (contacts.count == 0) {
                completionHandle(nil, error);
                return;
            }
            
            UIImage *image = [UIImage imageWithData:contacts[0].thumbnailImageData];
            completionHandle(image, nil);
            
        } @catch (NSException *e) {
            NSLog(@"ContactAdapter: Load image failed: %@", e);
            completionHandle(nil, error);
        }
    });
}

- (void)fetchContactsByPredicate:(NSPredicate *)predicate
                  withCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle {
    if (!completionHandle)
        return;
    
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter"
                                                code:200
                                            userInfo:@{@"Tải danh bạ thất bại": NSLocalizedDescriptionKey}];
    
    dispatch_async(self.serialQueue, ^{
        @try {
            NSArray<CNContact *> *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:self.keysToFetch error:nil];
            
            if (contacts.count == 0) {
                completionHandle(nil, error);
                return;
            }
            
            NSMutableArray<Contact *> *contactModels = [self getContactModelsFromCNContacts:contacts];
            completionHandle(contactModels, nil);
            
        } @catch (NSException *e) {
            NSLog(@"Load contact with predicate failed: %@", e);
            completionHandle(nil, error);
        }
    });
}


#pragma mark - ConvertCNContactToModel

- (NSMutableArray<Contact *> *)getContactModelsFromCNContacts:(NSArray<CNContact *> *)CNContacts {
    NSMutableArray<Contact *> *contacts = [[NSMutableArray alloc] init];
    
    for (CNContact *cnContact in CNContacts) {
        Contact *contact = [[Contact alloc] init];
        contact.identifier = cnContact.identifier;
        contact.name = [[NSString alloc] initWithFormat:@"%@ %@", cnContact.givenName, cnContact.familyName];
        contact.name = [StringHelper standardizeString:contact.name];
        
        if (cnContact.phoneNumbers.count > 0)
            contact.phoneNumber = [cnContact.phoneNumbers objectAtIndex:0].value.stringValue;
        else
            contact.phoneNumber = @"";
        
        [contacts addObject:contact];
    }
    
    return contacts;
}


#pragma mark - ContactAuthorizationStatusMethods

- (CNAuthorizationStatus)getAccessContactAuthorizationStatus {
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}

- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted))completionHandle {
    if (!completionHandle)
        return;
    
    [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts
                                            completionHandler:^(BOOL granted, NSError *error) {
        if (error || !granted) {
            completionHandle(false);
        } else {
            completionHandle(true);
        }
    }];
}

#pragma mark - ContactDidChangedHandlers

- (void)contactsDidChange {
    NSLog(@"ContactAdapter: Contact did changed!");
    
    [self refetchContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        if (error)
            return;
        
        for (int i = 0; i < self.contactDidChangedDelegates.count; i++) {
            id<ContactDidChangedDelegate> delegate = [self.contactDidChangedDelegates objectAtIndex:i];
            if (delegate && [delegate respondsToSelector:@selector(contactsDidChanged)]) {
                [delegate contactsDidChanged];
            }
        }
    }];
}

- (void)resigterContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate {
    if (!delegate)
        return;
    
    // Avoid run one task more times
    if ([self.contactDidChangedDelegates containsObject:delegate])
        return;

    @synchronized (self) {
        [self.contactDidChangedDelegates addObject:delegate];
    }
}

- (void)removeContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate {
    if (!delegate)
        return;
    
    @synchronized (self) {
        [self.contactDidChangedDelegates removeObject:delegate];
    }
}

#pragma mark - ForwardAllCompletionHandlers

- (void)forwardAllCompletionHandlers:(NSArray<Contact *> * _Nullable)contacts
                               error:(NSError * _Nullable)error {
    for (int i = 0; i < self.completionHandlers.count; i++) {
        self.completionHandlers[i](contacts, error);
    }
    
    [self.completionHandlers removeAllObjects];
}

@end
