//
//  ChatBoxViewController.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ChatBoxViewController.h"

#import "MessageTableNode.h"
#import "MessageInputView.h"
#import "MessageReactionNode.h"

#import "MessageBusiness.h"
#import "ContactBusiness.h"

#import "TextMessage.h"
#import "SinglePhotoMessage.h"

#import "AppConsts.h"
#import "ImageCache.h"
#import "StringHelper.h"

@interface ChatBoxViewController () <MessageTableNodeDelegate, MessageInputViewDelegate, MessageReactionNodeDelegate>

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) MessageTableNode *tableNode;
@property (nonatomic, strong) MessageInputView *messageInputView;
@property (nonatomic, strong) MessageReactionNode *reactionNode;

@property (nonatomic, strong) Conversation *conversation;
@property (nonatomic, strong) MessageBusiness *messageBusiness;

@property (nonatomic, strong) Contact *owner;
@property (nonatomic, strong) MessageCellNode *reactingCellNode;

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
        
        _owner = [[Contact alloc] init];
        _owner.name = @"Trần Hiếu";
        _owner.phoneNumber = kCurrentUser;
        
        _reactionNode = [[MessageReactionNode alloc] init];
        _reactionNode.delegate = self;
        
        _contentNode.automaticallyManagesSubnodes = YES;
        _contentNode.layoutSpecBlock = ^ASLayoutSpec *(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            weakSelf.tableNode.style.preferredSize = CGSizeMake(constrainedSize.max.width, constrainedSize.max.height - 50);
            
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                          child:weakSelf.tableNode];
        };
        [_contentNode layoutSpecBlock];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.node addSubnode:self.reactionNode];
    self.reactionNode.hidden = YES;
    
    _messageInputView = [[MessageInputView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kMessageInputHeight,
                                                                           self.view.bounds.size.width, kMessageInputHeight)];
    _messageInputView.delegate = self;
    [self.view addSubview:_messageInputView];
    
    self.navigationItem.title = _messageToContact.name;
    
    if (_friendImage) {
        [_tableNode setFriendAvatarImage:_friendImage];
    } else {
        NSString *shortName = [StringHelper getShortName:_messageToContact.name];
        [_tableNode setGradientColorCode:_friendImageColorCode
                            andShortName:shortName];
    }
    
    [self loadMessagesForConversation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMessagesForConversation {
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
}

#pragma mark - MessageTableNodeDelegate

- (void)tableNodeNeedLoadMoreDataWithCompletion:(void (^)(NSArray<Message *> *data))completionHandler {
    [_messageBusiness loadMessagesForConversation:_conversation
                                         loadMore:YES
                                completionHandler:^(NSArray<Message *> * _Nonnull messages, NSError * _Nonnull error) {
        if (!error && messages) {
            completionHandler(messages);
        }
    }];
}

- (void)tableNode:(MessageTableNode *)tableNode
didHoldInCellNode:(ASCellNode *)cellNode
      atIndexPath:(NSIndexPath *)indexPath
withRectOfCellNode:(CGRect)rectOfCell {
    if (!tableNode || !cellNode || !indexPath)
        return;
    
    [self.tableNode enableScroll:NO];
    self.reactingCellNode = (MessageCellNode *)cellNode;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat y = screenSize.height -  rectOfCell.origin.y - rectOfCell.size.height - 50;
    CGFloat x = (screenSize.width - 320) / 2.f;
    self.reactionNode.frame = CGRectMake(x, y, 320, 50);
    self.reactionNode.hidden = NO;
    
    self.reactionNode.view.transform = CGAffineTransformScale(self.reactionNode.view.transform, 0.3, 0.3);
    [UIView animateWithDuration:0.25 animations:^{
        self.reactionNode.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - HandleKeyboardShowing

- (void)handleKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        NSValue *keyboardFrame = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [keyboardFrame CGRectValue];
        
        [self animatedShowKeyboardWithHeight:keyboardRect.size.height];
    }
}

- (void)tableNode:(MessageTableNode *)tableNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.messageInputView endEditingWithKeepText:YES];
    [self animatedHideKeyboard];
    [self endReaction];
}

- (void)animatedShowKeyboardWithHeight:(CGFloat)keyboardHeight {
    [self endReaction];
    
    _contentNode.view.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.5 animations:^{
        self->_contentNode.view.transform = CGAffineTransformTranslate(self->_messageInputView.transform, 0, -keyboardHeight);
    }];
}

- (void)animatedHideKeyboard {
    [UIView animateWithDuration:0.15 animations:^{
        self->_contentNode.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - Action

- (void)sendMessage:(NSString *)message {
    if (!message)
        return;
    if (message.length == 0)
        return;
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    TextMessage *textMess = [[TextMessage alloc] initWithMessage:message
                                                     fromContact:self.owner
                                                       toContact:self.messageToContact
                                                       timestamp:timestamp];
    
    [self.tableNode sendMessage:textMess];
}

- (void)sendImage:(NSString *)imageUrl {
    if (!imageUrl)
        return;
    if (imageUrl.length == 0)
        return;
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    SinglePhotoMessage *mess = [[SinglePhotoMessage alloc] initWithPhotoURL:imageUrl
                                                                      ratio:1
                                                                fromContact:self.owner toContact:self.messageToContact
                                                                  timestamp:timestamp];
    
    [self.tableNode sendMessage:mess];
}

#pragma mark - MessageInputViewDelegate

- (void)messageInputViewDidEndEditing:(MessageInputView *)inputView {
    [self animatedHideKeyboard];
}

- (void)messageInputViewSendButtonTapped:(MessageInputView *)inputView
                         withMessageText:(NSString *)messageText {
    [self sendMessage:messageText];
}

- (void)messageInputViewCollapseButtonTapped:(MessageInputView *)inputView {
    [self animatedHideKeyboard];
}

- (void)messageInputViewSendLike:(MessageInputView *)inputView {
    [self sendImage:kFacebookLikeUrl];
}

- (void)messageInputViewSendSticker:(MessageInputView *)inputView {
    NSString *stickerUrl = [self.messageBusiness getRandomStickerUrl];
    [self sendImage:stickerUrl];
}

#pragma mark - MessageReactionNodeDelegate

- (void)messageReactionNode:(MessageReactionNode *)reactionNode didSelectReactionType:(NSInteger)reactionType {
    if ([self.reactingCellNode reactionType] == reactionType) {
        [self.reactingCellNode reaction:ReactionTypeNull];
    } else {
        [self.reactingCellNode reaction:reactionType];
    }
    
    [self endReaction];
}

#pragma mark -

- (void)endReaction {
    [_tableNode enableScroll:YES];
    
    if (!self.reactionNode.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            self.reactionNode.view.transform = CGAffineTransformScale(self.reactionNode.view.transform, 0.2, 0.2);
        } completion:^(BOOL finished) {
            self.reactionNode.hidden = YES;
            self.reactionNode.view.transform = CGAffineTransformIdentity;
        }];
    }
    
    if (self.reactingCellNode) {
        [self.reactingCellNode focusEndHandle];
        self.reactingCellNode = nil;
    }
}

@end
