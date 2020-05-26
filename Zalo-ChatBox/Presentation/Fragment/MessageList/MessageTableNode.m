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

static const int kFontSize = 18;
static NSString *kFontName = @"HelveticaNeue";
static const int kMaxMessageHeight = 300;

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

- (void)sortNeareastTimeFirst {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortedArray = [self.rawMessages sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.rawMessages = [NSMutableArray arrayWithArray:sortedArray];
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

#pragma mark - PublicMethods

- (void)setMessagesToTable:(NSArray<Message *> *)messages {
    if (messages) {
        [self.rawMessages removeAllObjects];
        self.rawMessages = [NSMutableArray arrayWithArray:messages];
        [self sortNeareastTimeFirst];
        [self generateSectionData];
        
        [self.tableModel setListArray:self.messageModels];
    }
}

- (void)reloadData {
    [_tableNode reloadData];
}

- (void)updateMoreMessages:(NSArray<Message *> *)messages {
    NSInteger currentSize = self.messageModels.count;
    [self.rawMessages addObjectsFromArray:messages];
    [self generateSectionData];
    
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = currentSize; i < self.messageModels.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
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

//#pragma mark - ASTableDataSource
//
//- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
//    return 1;
//}
//
//- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
//    return _models.count;
//}
//
//- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.item >= self.models.count)
//        return nil;
//
//    Message *mess = self.models[indexPath.item];
//    ASCellNode *(^cellNodeBlock)(void) = nil;
//    __weak MessageTableNode *weakSelf = self;
//
//    if (mess.style == MessageStyleText) {
//        cellNodeBlock = ^ASCellNode *() {
//            MessageCellNode *cellNode = [[MessageCellNode alloc] init];
//            cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cellNode setMessage:mess];
//            cellNode.delegate = self;
//
//            if (indexPath.item == 0 ||
//                ![weakSelf.models[indexPath.item - 1].fromPhoneNumber isEqualToString:mess.fromPhoneNumber]) {
//                if (weakSelf.friendAvatarImage) {
//                    [cellNode showAvatarImage:weakSelf.friendAvatarImage];
//                } else {
//                    [cellNode showAvatarImageWithGradientColor:weakSelf.gradientColorCode
//                                                     shortName:weakSelf.friendShortName];
//                }
//            }
//
//            return cellNode;
//        };
//
//    } else if (mess.style == MessageStyleSection) {
//        cellNodeBlock = ^ASCellNode *() {
//            TimeSectionCellNode *cellNode = [[TimeSectionCellNode alloc] init];
//            [cellNode setTimestamp:mess.timestamp];
//            cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
//
//            return cellNode;
//        };
//
//    } else {
//        cellNodeBlock = ^ASCellNode *() {
//            PhotoMessageCellNode *cellNode = [[PhotoMessageCellNode alloc] init];
//            [cellNode setMessage:mess];
//            cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cellNode setImageUrl:mess.message];
//            cellNode.delegate = self;
//
//            if (indexPath.item == 0 ||
//                ![weakSelf.models[indexPath.item - 1].fromPhoneNumber isEqualToString:mess.fromPhoneNumber]) {
//                if (weakSelf.friendAvatarImage) {
//                    [cellNode showAvatarImage:weakSelf.friendAvatarImage];
//                } else {
//                    [cellNode showAvatarImageWithGradientColor:weakSelf.gradientColorCode
//                                                     shortName:weakSelf.friendShortName];
//                }
//            }
//
//            return cellNode;
//        };
//    }
//
//    return cellNodeBlock;
//}

//- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.item >= self.models.count)
//        return ASSizeRangeZero;
//
//    Message *mess = self.models[indexPath.item];
//
//    if (mess.style == MessageStyleSection) {
//        return ASSizeRangeMake(CGSizeMake(self.view.bounds.size.width, 30));
//
//    } else if (mess.style == MessageStyleText) {
//        NSString *text = mess.message;
//        CGSize size = CGSizeMake(self.view.frame.size.width * 0.7, 1000);
//        CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:text
//                                                              font:[UIFont fontWithName:kFontName size:kFontSize]
//                                                       parrentSize:size];
//
//        return ASSizeRangeMake(CGSizeMake(estimatedFrame.size.width + 10, estimatedFrame.size.height + 20));
//
//    } else if (mess.style == MessageStyleImage) {
//        if ([_loadedImageMessages containsObject:mess]) {
//            CGFloat whRatio = mess.imageRatio;
//            if (whRatio >= 1) {
//                return ASSizeRangeMake(CGSizeMake(self.view.frame.size.width * 0.7, self.view.frame.size.width/whRatio));
//            } else {
//                return ASSizeRangeMake(CGSizeMake(kMaxMessageHeight * whRatio, kMaxMessageHeight));
//            }
//        } else {
//            return ASSizeRangeMake(CGSizeMake(100, 100));
//        }
//    }
//
//    return ASSizeRangeZero;
//}

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

#pragma mark - MessageCellNodeDelegate

- (void)didSelectMessageCellNode:(MessageCellNode *)cellNode {
    for (int i = 0; i < self.messageModels.count; i++) {
        ASCellNode *node = [_tableNode nodeForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([node isKindOfClass:[MessageCellNode class]]) {
            MessageCellNode *messNode = (MessageCellNode *)node;
            if (messNode.choosing) {
                [messNode deselectCell];
                [self removeSectionCellForUnselectCell:messNode];
            }
        }
    }
    
    [cellNode selectCell];
    NSInteger index = [_tableNode indexPathForNode:cellNode].item;
    if (index == self.rawMessages.count - 1)
        return;
    
    if ([self.messageModels[index + 1] isKindOfClass:[TimeSectionHeader class]]) {
        return;
    }
    
    NSTimeInterval timestamp = [self timestampOfObject:self.messageModels[index]];
    [self.messageModels insertObject:[[TimeSectionHeader alloc] initWithTimestamp:timestamp]
                             atIndex:index + 1];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]]
                          withRowAnimation:YES];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableNode:didSelectItemAtIndexPath:)]) {
            [self.delegate tableNode:self
            didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }];
}

- (void)didUnselectMessageCellNode:(MessageCellNode *)cellNode {
    [cellNode deselectCell];
    [self removeSectionCellForUnselectCell:cellNode];
}

- (void)removeSectionCellForUnselectCell:(MessageCellNode *)cellNode {
    NSInteger index = [_tableNode indexPathForNode:cellNode].item;
    if (index >= self.messageModels.count - 2)
        return;
    
    if (![self.messageModels[index + 1] isKindOfClass:[TimeSectionHeader class]])
        return;
    else if ([self timestampOfObject:self.messageModels[index + 1]] - [self timestampOfObject:self.messageModels[index + 2]]
             >= kMessageSectionTimeSpace)
        return;
    
    [self.messageModels removeObjectAtIndex:index + 1];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]]
                          withRowAnimation:YES];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableNode:didSelectItemAtIndexPath:)]) {
            [self.delegate tableNode:self
            didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }];
}

@end
