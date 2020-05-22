//
//  ChatBoxViewController.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ChatBoxViewController.h"

#import "MessageTableNode.h"
#import "MessageInputNode.h"

#import "MessageBusiness.h"
#import "ContactBusiness.h"

#import "AppConsts.h"
#import "ImageCache.h"
#import "StringHelper.h"

@interface ChatBoxViewController () <MessageTableNodeDelegate, MessageInputNodeDelegate>

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) MessageTableNode *tableNode;
@property (nonatomic, strong) MessageInputNode *messageInputNode;

@property (nonatomic, strong) Conversation *conversation;
@property (nonatomic, strong) MessageBusiness *messageBusiness;

@end

@implementation ChatBoxViewController

- (instancetype)init {
    _contentNode = [[ASDisplayNode alloc] init];
    self = [super initWithNode:_contentNode];
    if (self) {
        __weak ChatBoxViewController *weakSelf = self;
        
        _tableNode = [[MessageTableNode alloc] init];
        _tableNode.delegate = self;
        
        _messageBusiness = [[MessageBusiness alloc] init];
        
        _messageInputNode = [[MessageInputNode alloc] init];
        _messageInputNode.delegate = self;
        
        _contentNode.automaticallyManagesSubnodes = YES;
        _contentNode.layoutSpecBlock = ^ASLayoutSpec *(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            weakSelf.tableNode.style.preferredSize = CGSizeMake(constrainedSize.max.width, constrainedSize.max.height - 50);
            weakSelf.tableNode.backgroundColor = [UIColor whiteColor];
            
            weakSelf.messageInputNode.style.preferredSize = CGSizeMake(constrainedSize.max.width, 50);
            
            ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                                   spacing:0
                                                                            justifyContent:ASStackLayoutJustifyContentStart
                                                                                alignItems:ASStackLayoutAlignItemsCenter
                                                                                  children:@[weakSelf.tableNode, weakSelf.messageInputNode]];
            
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                          child:stackSpec];
        };
        [_contentNode layoutSpecBlock];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = _messageToContact.name;
    
    if (_friendImage) {
        [_tableNode setFriendAvatarImage:_friendImage];
    } else {
        NSString *shortName = [StringHelper getShortName:_messageToContact.name];
        [_tableNode setGradientColorCode:_friendImageColorCode andShortName:shortName];
    }
    
    Contact *currentUser = [[Contact alloc] init];
    currentUser.phoneNumber = kCurrentUser;
    
    _conversation = [_messageBusiness getConversationOfContact:currentUser
                                                    andContact:_messageToContact];
    
    __weak ChatBoxViewController *weakSelf = self;
    [_messageBusiness loadMessagesForConversation:_conversation
                                         loadMore:NO
                                completionHandler:^(NSArray<Message *> *messages, NSError *error) {
        if (!error && messages) {
            [weakSelf.tableNode setMessagesToTable:messages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableNode reloadData];
            });
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - MessageTableNodeDelegate

- (void)tableNodeNeedLoadMoreData {
    __weak ChatBoxViewController *weakSelf = self;
    [_messageBusiness loadMessagesForConversation:_conversation
                                         loadMore:YES
                                completionHandler:^(NSArray<Message *> * _Nonnull messages, NSError * _Nonnull error) {
        if (!error && messages) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf.tableNode updateMoreMessages:messages];
            });
        }
    }];
}

#pragma mark - HandleKeyboardShowing

- (void)handleKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        NSValue *keyboardFrame = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [keyboardFrame CGRectValue];
        
        _contentNode.view.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.5 animations:^{
            self->_contentNode.view.transform = CGAffineTransformTranslate(self->_messageInputNode.view.transform, 0, -keyboardRect.size.height);
        }];
    }
}

- (void)tableNode:(MessageTableNode *)tableNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_messageInputNode endEditing];
    [UIView animateWithDuration:0.15 animations:^{
        self->_contentNode.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - MessageInputNodeDelegate

- (void)sendMessage:(NSString *)message {
    if (!message)
        return;
    if (message.length == 0)
        return;
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    Message *messageModel = [[Message alloc] initWithMessage:message
                                                        from:kCurrentUser
                                                          to:_messageToContact.phoneNumber
                                                   timestamp:timestamp
                                                       style:MessageStyleText];
    
    [_tableNode sendMessage:messageModel];
}

@end
