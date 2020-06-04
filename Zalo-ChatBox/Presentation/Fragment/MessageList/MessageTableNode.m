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
static const int kMaxNodes = 300;

@interface MessageTableNode () <ASTableDelegate, ASTableDataSource, MessageCellNodeDelegate>

@property (nonatomic, strong) NSMutableArray<Message *> *rawMessages;
@property (nonatomic, strong) NSMutableArray<id<CellNodeObject>> *messageModels;

@property (nonatomic, strong) NSMutableArray<id<CellNodeObject>> *topLoadedModels;
@property (nonatomic, strong) NSMutableArray<id<CellNodeObject>> *bottomLoadedModels;

@property (nonatomic, strong) ASTableNode *tableNode;
@property (nonatomic, strong) TableNodeModel *tableModel;
@property (nonatomic, strong) CellNodeFactory *factory;

@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL needLoadMore;

@property (nonatomic, strong) UIImage *friendAvatarImage;
@property (nonatomic, assign) int gradientColorCode;
@property (nonatomic, strong) NSString *friendShortName;

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
        _tableNode.leadingScreensForBatching = 3;
        _tableNode.backgroundColor = [UIColor whiteColor];
        
        _topLoadedModels = [[NSMutableArray alloc] init];
        _bottomLoadedModels = [[NSMutableArray alloc] init];
        
        _canLoadMore = YES;
        _needLoadMore = NO;
        
        _rawMessages = [[NSMutableArray alloc] init];
        _messageModels = [[NSMutableArray alloc] init];
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
    _tableNode.contentInset = UIEdgeInsetsMake(-inset + kMessageInputHeight, 0, inset, 0);
    _tableNode.view.scrollIndicatorInsets = UIEdgeInsetsMake(-inset + kMessageInputHeight + 10, 0, inset, 0);
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

- (void)generateNewSectionData:(NSArray<Message *> *)messages {
    for (int i = 0; i < messages.count; i++) {
        if (messages[i].timestamp - [self.rawMessages lastObject].timestamp >= kMessageSectionTimeSpace
            && ![[self.messageModels lastObject] isKindOfClass:[TimeSectionHeader class]]) {
            
            TimeSectionHeader *object = [[TimeSectionHeader alloc] initWithTimestamp:self.rawMessages[i].timestamp];
            [self.messageModels addObject:object];
        }
        
        [self.rawMessages addObject:messages[i]];
        [self.messageModels addObject:messages[i]];
    }
}

- (void)groupMessages {
    if (self.messageModels.count == 0)
        return;
    
    // Group messages for show avatar
    for (int i = 1; i < self.messageModels.count; i++) {
        if (!(self.messageModels[i].class == self.messageModels[i - 1].class) &&
            [self.messageModels[i].class isSubclassOfClass:[Message class]]) {
            Message *message = (Message *)self.messageModels[i];
            message.showAvatar = YES;
            
            if (message.class == [TextMessage class]) {
                TextMessage *textMessage = (TextMessage *)message;
                textMessage.showTail = YES;
            }
            
        } else if ([self.messageModels[i].class isSubclassOfClass:[Message class]]) {
            Message *currentMessage = (Message *)self.messageModels[i];
            Message *prevMessage = (Message *)self.messageModels[i - 1];
            if (currentMessage.fromContact.identifier != prevMessage.fromContact.identifier) {
                currentMessage.showAvatar = YES;
                
                if (currentMessage.class == [TextMessage class]) {
                    TextMessage *textMessage = (TextMessage *)currentMessage;
                    textMessage.showTail = YES;
                }
            }
        }
    }
    Message *message = (Message *)self.messageModels[0];
    message.showAvatar = YES;
    if (message.class == [TextMessage class]) {
        ((TextMessage *)message).showTail = YES;
    }
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
        self->_needLoadMore = YES;
    }];
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
        
        [_tableModel pushFront:@[timeHeader]];
        
    } else if (self.messageModels[0].class == [TextMessage class] &&
               ((Message *)self.messageModels[0]).fromContact == message.fromContact) {
        ((TextMessage *)self.messageModels[0]).showTail = NO;
    }
    
    [self.messageModels insertObject:message atIndex:0];
    [indexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    // Config
    if (message.class == [TextMessage class]) {
        ((TextMessage *)message).showTail = YES;
    }
    
    [_tableModel pushFront:@[message]];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
        [_tableNode insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    } completion:^(BOOL finished) {
        [self.tableNode scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:YES];
    }];
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

- (void)tableNode:(ASTableNode *)tableNode willBeginBatchFetchWithContext:(ASBatchContext *)context {
    if (!self.needLoadMore) {
        [context completeBatchFetching:YES];
        return;
    }
    
    if (self.topLoadedModels.count >= 30) {
        [self updateMoreMessages:nil];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableNodeNeedLoadMoreDataWithCompletion:)]) {
        [self.delegate tableNodeNeedLoadMoreDataWithCompletion:^(NSArray<Message *> *data) {
#if DEBUG
            assert(![NSThread isMainThread]);
#endif

            if (data) {
                [self updateMoreMessages:data];
            }
            
            [context completeBatchFetching:YES];
        }];
    }
}

#pragma mark - LoadMoreAndSaveMemory

- (void)updateMoreMessages:(NSArray<Message *> *)messages {
#if DEBUG
    assert(![NSThread isMainThread]);
#endif
    NSInteger currentModelsSize = self.messageModels.count;
    
    // Update models (all data here)
    [self generateNewSectionData:messages];
    [self groupMessages];
    
    NSMutableArray<id<CellNodeObject>> *insertData = [[NSMutableArray alloc] init];
    NSMutableArray<NSIndexPath *> *insertIndexes = [[NSMutableArray alloc] init];
    
    for (NSInteger i = currentModelsSize; i < self.messageModels.count; i++) {
        [insertData addObject:self.messageModels[i]];
        [insertIndexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [self.tableModel pushBack:insertData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableNode performBatchUpdates:^{
            [self.tableNode insertRowsAtIndexPaths:insertIndexes
                                  withRowAnimation:UITableViewRowAnimationNone];
        } completion:nil];
    });
    
//    // Add new value to topLoadedModels
//    for (NSInteger i = currentModelsSize; i < self.messageModels.count; i++) {
//        [self.topLoadedModels addObject:self.messageModels[i]];
//    }
//
//    NSInteger currentSize = [self.tableModel dataSourceCount];
//    NSInteger addingSize = self.topLoadedModels.count >= 30 ? 30 : self.topLoadedModels.count;
//    NSInteger removeNodeSize = 0;
//
//    if (currentSize + addingSize > kMaxNodes) {
//        removeNodeSize = currentSize + addingSize - kMaxNodes;
//    }
//
//    NSMutableArray<id<CellNodeObject>> *addObjects = [[NSMutableArray alloc] init];
//    NSMutableArray<id<CellNodeObject>> *removeObjects = [[NSMutableArray alloc] init];
//
//    NSMutableArray<NSIndexPath *> *addIndexPaths = [[NSMutableArray alloc] init];
//    NSMutableArray<NSIndexPath *> *removeIndexPaths = [[NSMutableArray alloc] init];
//
//    // Build remove changeset
//    for (NSInteger i = self.bottomLoadedModels.count; i < self.bottomLoadedModels.count + removeNodeSize; i++) {
//        [removeObjects addObject:self.messageModels[i]];
//        [removeIndexPaths addObject:[NSIndexPath indexPathForRow:i - self.bottomLoadedModels.count
//                                                       inSection:0]];
//    }
//    [self.tableModel remove:removeObjects];
//
//    // Build insert changeset
//    for (NSInteger i = self.bottomLoadedModels.count + currentSize; i < self.bottomLoadedModels.count + currentSize + addingSize; i++) {
//        [addObjects addObject:self.messageModels[i]];
//        [addIndexPaths addObject:[NSIndexPath indexPathForRow:[self.tableModel dataSourceCount] + i - self.bottomLoadedModels.count - currentSize
//                                                    inSection:0]];
//    }
//    [self.tableModel pushBack:addObjects];
//
//    [self.topLoadedModels removeObjectsInArray:addObjects];
//    [self.bottomLoadedModels addObjectsFromArray:removeObjects];
//
//    __weak MessageTableNode *weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.tableNode performBatchAnimated:NO updates:^{
//            [self.tableNode deleteRowsAtIndexPaths:removeIndexPaths
//                                  withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableNode insertRowsAtIndexPaths:addIndexPaths
//                                    withRowAnimation:UITableViewRowAnimationNone];
//        } completion:^(BOOL finished) {
//
//        }];
//    });
}

- (void)loadBottomMessage {
    
}


@end
