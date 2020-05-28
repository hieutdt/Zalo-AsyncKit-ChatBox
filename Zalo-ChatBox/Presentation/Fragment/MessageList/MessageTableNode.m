//
//  MessageTableNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageTableNode.h"

#import "MessageCellNode.h"
#import "TimeSectionCellNode.h"
#import "PhotoMessageCellNode.h"
#import "TimeSectionHeader.h"

#import "TableNodeModel.h"
#import "CellNodeFactory.h"

#import "AppConsts.h"
#import "ImageCache.h"
#import "LayoutHelper.h"
#import "UIImage+Additions.h"

static NSString *kFontName = @"HelveticaNeue";

@interface MessageTableNode () <ASTableDelegate, ASTableDataSource, MessageCellNodeDelegate>

@property (nonatomic, strong) NSMutableArray<Message *> *rawMessages;
@property (nonatomic, strong) NSMutableArray<id<CellNodeObject>> *messageModels;

@property (nonatomic, strong) ASTableNode *tableNode;
@property (nonatomic, strong) TableNodeModel *tableModel;
@property (nonatomic, strong) CellNodeFactory *factory;

@property (nonatomic, assign) BOOL canLoadMore;

@property (nonatomic, strong) UIImage *friendAvatarImage;
@property (nonatomic, assign) int gradientColorCode;
@property (nonatomic, strong) NSString *friendShortName;

@property (nonatomic, strong) NSMutableArray<Message *> *loadedImageMessages;

@end

@implementation MessageTableNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _factory = [[CellNodeFactory alloc] init];
        _tableModel = [[TableNodeModel alloc] init];
        _tableModel.delegate = _factory;
        
        _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStyleGrouped];
        _tableNode.inverted = YES;
        _tableNode.dataSource = _tableModel;
        _tableNode.delegate = self;
        
        _canLoadMore = YES;
        
        _rawMessages = [[NSMutableArray alloc] init];
        _messageModels = [[NSMutableArray alloc] init];
        
        _loadedImageMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                  child:_tableNode];
}

- (void)didLoad {
    [super didLoad];
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //TODO: Need get top bar height here
    CGFloat inset = 80;
    _tableNode.contentInset = UIEdgeInsetsMake(-inset, 0, inset, 0);
    _tableNode.view.scrollIndicatorInsets = UIEdgeInsetsMake(-inset, 0, inset, 0);
}

#pragma mark - GenerateSectionsData

- (void)sortNeareastTimeFirst:(NSMutableArray<Message *> *)array {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
    array = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)generateSectionData {
    // Insert section lines between message groups that are separated by time
    if (!self.rawMessages)
        return;
    if (self.rawMessages.count == 0)
        return;
    
    [self.messageModels removeAllObjects];
    
    for (int i = 0; i < self.rawMessages.count - 1; i++) {
        [self.messageModels addObject:self.rawMessages[i]];
        
        if (self.rawMessages[i].timestamp - self.rawMessages[i + 1].timestamp >= kMessageSectionTimeSpace
            && ![[self.messageModels lastObject] isKindOfClass:[TimeSectionHeader class]]) {
            
            TimeSectionHeader *object = [[TimeSectionHeader alloc] initWithTimestamp:self.rawMessages[i].timestamp];
            [self.messageModels addObject:object];
        }
    }
    
    TimeSectionHeader *object = [[TimeSectionHeader alloc] initWithTimestamp:self.rawMessages[self.rawMessages.count - 1].timestamp];
    [self.messageModels addObject:object];
}

- (void)groupMessages {
    if (self.messageModels.count == 0)
        return;
    
    for (int i = 1; i < self.messageModels.count; i++) {
        if (!(self.messageModels[i].class == self.messageModels[i - 1].class) &&
            [self.messageModels[i].class isSubclassOfClass:[Message class]]) {
            Message *message = (Message *)self.messageModels[i];
            message.showAvatar = YES;
            
            if ([message.class isKindOfClass:[TextMessage class]]) {
                TextMessage *textMessage = (TextMessage *)message;
                textMessage.showTail = YES;
            }
            
        } else if ([self.messageModels[i].class isSubclassOfClass:[Message class]]) {
            Message *currentMessage = (Message *)self.messageModels[i];
            Message *prevMessage = (Message *)self.messageModels[i - 1];
            if (currentMessage.fromContact.identifier != prevMessage.fromContact.identifier) {
                currentMessage.showAvatar = YES;
                
                if ([currentMessage.class isKindOfClass:[TextMessage class]]) {
                    TextMessage *textMessage = (TextMessage *)currentMessage;
                    textMessage.showTail = YES;
                }
            }
        }
    }
    
    Message *message = (Message *)self.messageModels[0];
    message.showAvatar = YES;
}

#pragma mark - PublicMethods

- (void)setMessagesToTable:(NSArray<Message *> *)messages {
    if (messages) {
        [self.rawMessages removeAllObjects];
        self.rawMessages = [NSMutableArray arrayWithArray:messages];
        [self sortNeareastTimeFirst:self.rawMessages];
        [self generateSectionData];
        [self groupMessages];
        
        [self.tableModel setListArray:self.messageModels];
    }
}

- (void)reloadData {
    [_tableNode reloadDataWithCompletion:^{
        
    }];
}

- (void)updateMoreMessages:(NSArray<Message *> *)messages {
    NSInteger currentSize = self.messageModels.count;
    [self.rawMessages addObjectsFromArray:messages];
    [self generateSectionData];
    [self groupMessages];
    
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = currentSize; i < self.messageModels.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableModel setListArray:self.messageModels];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:NO];
    } completion:nil];
}

- (void)sendMessage:(Message *)message {
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    
    NSTimeInterval lastTs = message.timestamp;
    if (self.messageModels.count > 0)
        lastTs = [self timestampOfObject:self.messageModels[0]];
    
    if (message.timestamp - lastTs >= kMessageSectionTimeSpace) {
        TimeSectionHeader *timeHeader = [[TimeSectionHeader alloc] initWithTimestamp:message.timestamp];
        [self.messageModels insertObject:timeHeader atIndex:0];
        [indexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    
    [self.messageModels insertObject:message atIndex:0];
    [indexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    } completion:nil];
}

- (NSTimeInterval)timestampOfObject:(id)object {
    if (!object)
        return 0;
    if ([object isKindOfClass:[TimeSectionHeader class]]) {
        TimeSectionHeader *timeObj = (TimeSectionHeader *)object;
        return timeObj.timestamp;
        
    } else if ([[object class] isSubclassOfClass:[Message class]]) {
        Message *messObj = (Message *)object;
        return messObj.timestamp;
    }
    return 0;
}

- (void)setFriendAvatarImage:(UIImage *)image {
    if (image)
        _friendAvatarImage = image;
}

- (void)setGradientColorCode:(int)gradientColorCode
                andShortName:(NSString *)shortName {
    _gradientColorCode = gradientColorCode;
    _friendShortName = shortName;
    _friendAvatarImage = nil;
}

#pragma mark - ASTableDelegate

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // To hide keyboard only
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableNode:didSelectItemAtIndexPath:)]) {
        [self.delegate tableNode:self didSelectItemAtIndexPath:indexPath];
    }
}

- (void)tableNode:(ASTableNode *)tableNode willDisplayRowWithNode:(ASCellNode *)node {
    if (!_canLoadMore)
        return;
    
    NSIndexPath *indexPath = [_tableNode indexPathForNode:node];
    if (indexPath.item == self.messageModels.count - 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableNodeNeedLoadMoreData)]) {
            [self.delegate tableNodeNeedLoadMoreData];
        }
    }
}

@end
