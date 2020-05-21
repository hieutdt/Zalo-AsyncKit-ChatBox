//
//  ContactListViewController.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactListViewController.h"
#import "ContactTableNode.h"
#import "ContactBusiness.h"
#import "ImageCache.h"
#import "ChatBoxViewController.h"


@interface ContactListViewController () <ContactTableNodeDelegate>

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem *searchBarButtonItem;
@property (nonatomic, strong) ContactTableNode *tableNode;

@property (nonatomic, strong) ContactBusiness *contactBusiness;

@property (nonatomic, strong) NSMutableArray<Contact *> *contacts;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *contactSections;
@property (nonatomic, strong) NSMutableArray<ContactTableViewModel *> *viewModels;

@end

@implementation ContactListViewController

- (instancetype)init {
    _contentNode = [[ASDisplayNode alloc] init];
    self = [super initWithNode:_contentNode];
    if (self) {
        _tableNode = [[ContactTableNode alloc] init];
        _tableNode.backgroundColor = [UIColor yellowColor];
        _tableNode.delegate = self;
        _contentNode.automaticallyManagesSubnodes = YES;
        
        __weak ContactListViewController *weakSelf = self;
        _contentNode.layoutSpecBlock = ^ASLayoutSpec *(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            weakSelf.tableNode.style.preferredSize = constrainedSize.max;
            
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                          child:weakSelf.tableNode];
        };
        [_contentNode layoutSpecBlock];
        
        _contactBusiness = [[ContactBusiness alloc] init];
        _contactSections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, width - 80, 50)];
    _searchBar.placeholder = @"Tìm kiếm bạn bè ...";
    
    _searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
    self.navigationItem.leftBarButtonItem = _searchBarButtonItem;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    [self checkPermissionAndLoadContacts];
}

#pragma mark - LoadContacts

- (void)checkPermissionAndLoadContacts {
    ContactAuthorState authorizationState = [self.contactBusiness permissionStateToAccessContactData];
    switch (authorizationState) {
        case ContactAuthorStateAuthorized: {
            [self loadContacts];
            break;
        }
        case ContactAuthorStateDenied: {
            [self showNotPermissionView];
            break;
        }
        default: {
            [self.contactBusiness requestAccessWithCompletionHandle:^(BOOL granted) {
                if (granted) {
                    [self loadContacts];
                } else {
                    [self showNotPermissionView];
                }
            }];
            break;
        }
    }
}

- (void)showNotPermissionView {
    
}

- (void)loadContacts {
    [self.contactBusiness loadContactsWithCompletion:^(NSArray<Contact *> *contacts, NSError *error) {
        if (!error) {
            if (contacts.count > 0) {
                [self initContactsData:contacts];
                self.viewModels = [self getPickerModelsArrayFromContacts:self.contacts];
                [self.tableNode setViewModels:self.viewModels];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableNode reloadData];
                });
            }
        }
    }];
}

- (void)initContactsData:(NSArray<Contact *> *)contacts {
    if (!contacts)
        return;
    
    self.contacts = [NSMutableArray arrayWithArray:contacts];
    self.contactSections = [self.contactBusiness sortedByAlphabetSectionsArrayFromContacts:self.contacts];
}

- (NSMutableArray<ContactTableViewModel *> *)getPickerModelsArrayFromContacts:(NSArray<Contact *> *)contacts {
    if (!contacts) {
        return nil;
    }
    
    NSMutableArray<ContactTableViewModel *> *viewModels = [[NSMutableArray alloc] init];
    
    for (Contact *contact in contacts) {
        ContactTableViewModel *viewModel = [[ContactTableViewModel alloc] init];
        viewModel.identifier = contact.identifier;
        viewModel.name = contact.name;
        
        [viewModels addObject:viewModel];
    }
    
    return viewModels;
}

#pragma mark - ContactTableNodeDelegate

- (void)contactTableNode:(ContactTableNode *)tableNode
     loadImageToCellNode:(ContactTableCellNode *)cellNode
             atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.contactSections.count)
        return;
    if (indexPath.item >= self.contactSections[indexPath.section].count)
        return;
    
    Contact *contact = self.contactSections[indexPath.section][indexPath.item];
    if (!contact)
        return;
    
    UIImage *imageFromCache = [[ImageCache instance] imageForKey:contact.identifier];
    if (imageFromCache) {
        [cellNode setAvatar:imageFromCache];
    } else {
        [self.contactBusiness loadContactImageByID:contact.identifier
                                        completion:^(UIImage *image, NSError *error) {
            [[ImageCache instance] setImage:image forKey:contact.identifier];
            [cellNode setAvatar:image];
        }];
    }
}


- (void)contactTableNode:(ContactTableNode *)tableNode
didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.contactSections.count)
        return;
    if (indexPath.item >= self.contactSections[indexPath.section].count)
        return;
    
    Contact *contact = self.contactSections[indexPath.section][indexPath.item];
    if (!contact)
        return;
    
    NSInteger index = [_contacts indexOfObject:contact];
    ContactTableViewModel *viewModel = _viewModels[index];
    NSInteger gradientColorCode = viewModel.gradientColorCode;
    
    ChatBoxViewController *vc = [[ChatBoxViewController alloc] init];
    vc.messageToContact = contact;
    
    UIImage *friendImage = [[ImageCache instance] imageForKey:contact.identifier];
    if (friendImage) {
        vc.friendImage = friendImage;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        [_contactBusiness loadContactImageByID:contact.identifier completion:^(UIImage *image, NSError *error) {
            if (image)
                vc.friendImage = image;
            else
                vc.friendImageColorCode = (int)gradientColorCode;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:vc animated:YES];
            });
        }];
    }
}

@end
