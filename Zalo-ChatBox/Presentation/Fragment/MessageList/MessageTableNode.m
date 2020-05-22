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

#import "AppConsts.h"
#import "ImageCache.h"
#import "LayoutHelper.h"
#import "UIImage+Additions.h"

static const int kFontSize = 18;
static NSString *kFontName = @"HelveticaNeue";
static const int kMaxMessageHeight = 300;

@interface MessageTableNode () <ASTableDelegate, ASTableDataSource, MessageCellNodeDelegate, PhotoMessageCellNodeDelegate>

@property (nonatomic, strong) NSMutableArray<Message *> *messages;
@property (nonatomic, strong) NSMutableArray<Message *> *models;
@property (nonatomic, strong) NSMutableArray<NSString *> *sectionTitles;

@property (nonatomic, strong) ASTableNode *tableNode;

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
        
        _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStyleGrouped];
        _tableNode.inverted = YES;
        _tableNode.dataSource = self;
        _tableNode.delegate = self;
        
        _canLoadMore = YES;
        
        _models = [[NSMutableArray alloc] init];
        _sectionTitles = [[NSMutableArray alloc] init];
        
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
    CGFloat inset = 50;
    _tableNode.contentInset = UIEdgeInsetsMake(-inset, 0, inset, 0);
    _tableNode.view.scrollIndicatorInsets = UIEdgeInsetsMake(-inset, 0, inset, 0);
}

#pragma mark - GenerateSectionsData

- (void)sortNeareastTimeFirst {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortedArray = [_messages sortedArrayUsingDescriptors:@[sortDescriptor]];
    _messages = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)generateSectionData {
    // Insert section lines between message groups that are separated by time
    if (!_messages)
        return;
    if (_messages.count == 0)
        return;
    
    NSMutableArray *cellModels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _messages.count - 1; i++) {
        if (_messages[i].style != MessageStyleSection)
            [cellModels addObject:_messages[i]];
        if (_messages[i].timestamp - _messages[i + 1].timestamp >= kMessageSectionTimeSpace
            && [_models lastObject].style != MessageStyleSection) {
            Message *sectionRow = [self sectionRowByTimestamp:_messages[i].timestamp];
            [cellModels addObject:sectionRow];
        }
    }
    
    Message *sectionRow = [self sectionRowByTimestamp:_messages[_messages.count - 1].timestamp];
    [cellModels addObject:sectionRow];
    
    [_models removeAllObjects];
    _models = [NSMutableArray arrayWithArray:cellModels];
}

- (Message *)sectionRowByTimestamp:(NSTimeInterval)timestamp {
    Message *sectionRow = [[Message alloc] initWithMessage:@"" from:@"" to:@""
                                                 timestamp:timestamp
                                                     style:MessageStyleSection];
    return sectionRow;
}

#pragma mark - PublicMethods

- (void)setMessagesToTable:(NSArray<Message *> *)messages {
    if (messages) {
        [_messages removeAllObjects];
        _messages = [NSMutableArray arrayWithArray:messages];
        [self sortNeareastTimeFirst];
        [self generateSectionData];
    }
}

- (void)reloadData {
    [_tableNode reloadData];
}

- (void)scrollToBottom {
    [_tableNode scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_models.count - 1 inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:NO];
}

- (void)updateMoreMessages:(NSArray<Message *> *)messages {
    NSInteger currentSize = _models.count;
    [_messages addObjectsFromArray:messages];
    [self generateSectionData];
    
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = currentSize; i < _models.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    [_tableNode performBatchUpdates:^{
        [_tableNode insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:NO];
    } completion:nil];
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

#pragma mark - ASTableDataSource

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return _models.count;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.models.count)
        return nil;
    
    Message *mess = self.models[indexPath.item];
    ASCellNode *(^cellNodeBlock)(void) = nil;
    __weak MessageTableNode *weakSelf = self;
    
    if (mess.style == MessageStyleText) {
        cellNodeBlock = ^ASCellNode *() {
            MessageCellNode *cellNode = [[MessageCellNode alloc] init];
            cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
            [cellNode setMessage:mess];
            cellNode.delegate = self;
            
            if (indexPath.item == 0 ||
                ![weakSelf.models[indexPath.item - 1].fromPhoneNumber isEqualToString:mess.fromPhoneNumber]) {
                if (weakSelf.friendAvatarImage) {
                    [cellNode showAvatarImage:weakSelf.friendAvatarImage];
                } else {
                    [cellNode showAvatarImageWithGradientColor:weakSelf.gradientColorCode
                                                     shortName:weakSelf.friendShortName];
                }
            }
    
            return cellNode;
        };
        
    } else if (mess.style == MessageStyleSection) {
        cellNodeBlock = ^ASCellNode *() {
            TimeSectionCellNode *cellNode = [[TimeSectionCellNode alloc] init];
            [cellNode setTimestamp:mess.timestamp];
            cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cellNode;
        };
        
    } else {
        cellNodeBlock = ^ASCellNode *() {
            PhotoMessageCellNode *cellNode = [[PhotoMessageCellNode alloc] init];
            [cellNode setMessage:mess];
            cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
            [cellNode setImageUrl:mess.message];
            cellNode.delegate = self;
            
            if (indexPath.item == 0 ||
                ![weakSelf.models[indexPath.item - 1].fromPhoneNumber isEqualToString:mess.fromPhoneNumber]) {
                if (weakSelf.friendAvatarImage) {
                    [cellNode showAvatarImage:weakSelf.friendAvatarImage];
                } else {
                    [cellNode showAvatarImageWithGradientColor:weakSelf.gradientColorCode
                                                     shortName:weakSelf.friendShortName];
                }
            }
            
            return cellNode;
        };
    }
    
    return cellNodeBlock;
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.models.count)
        return ASSizeRangeZero;
    
    Message *mess = self.models[indexPath.item];
    
    if (mess.style == MessageStyleSection) {
        return ASSizeRangeMake(CGSizeMake(self.view.bounds.size.width, SECTION_HEADER_HEIGHT));
        
    } else if (mess.style == MessageStyleText) {
        NSString *text = mess.message;
        CGSize size = CGSizeMake(self.view.frame.size.width * 0.7, 1000);
        CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:text
                                                              font:[UIFont fontWithName:kFontName size:kFontSize]
                                                       parrentSize:size];
    
        return ASSizeRangeMake(CGSizeMake(estimatedFrame.size.width + 10, estimatedFrame.size.height + 20));
    } else if (mess.style == MessageStyleImage) {
        if ([_loadedImageMessages containsObject:mess]) {
            CGFloat whRatio = mess.imageRatio;
            if (whRatio >= 1) {
                return ASSizeRangeMake(CGSizeMake(self.view.frame.size.width * 0.7, self.view.frame.size.width/whRatio));
            } else {
                return ASSizeRangeMake(CGSizeMake(kMaxMessageHeight * whRatio, kMaxMessageHeight));
            }
        } else {
            return ASSizeRangeMake(CGSizeMake(100, 100));
        }
    }
    
    return ASSizeRangeZero;
}

#pragma mark - ASTableDelegate

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableNode:(ASTableNode *)tableNode willDisplayRowWithNode:(ASCellNode *)node {
    if (!_canLoadMore)
        return;
    
    NSIndexPath *indexPath = [_tableNode indexPathForNode:node];
    if (indexPath.item == _models.count - 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableNodeNeedLoadMoreData)]) {
            [self.delegate tableNodeNeedLoadMoreData];
        }
    }
}

#pragma mark - MessageCellNodeDelegate

- (void)didSelectMessageCellNode:(MessageCellNode *)cellNode {
    for (int i = 0; i < _models.count; i++) {
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
    if (index == _messages.count - 1)
        return;
    
    if (_models[index + 1].style == MessageStyleSection) {
        return;
    }
    
    [_models insertObject:[[Message alloc] initWithMessage:@"" from:@"" to:@""
                                                 timestamp:_models[index].timestamp
                                                     style:MessageStyleSection]
                  atIndex:index + 1];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]]
                          withRowAnimation:YES];
    } completion:nil];
}

- (void)didUnselectMessageCellNode:(MessageCellNode *)cellNode {
    [cellNode deselectCell];
    [self removeSectionCellForUnselectCell:cellNode];
}

- (void)removeSectionCellForUnselectCell:(MessageCellNode *)cellNode {
    NSInteger index = [_tableNode indexPathForNode:cellNode].item;
    if (index >= _models.count - 2)
        return;
    
    if (_models[index + 1].style != MessageStyleSection)
        return;
    else if (_models[index + 1].timestamp - _models[index + 2].timestamp >= kMessageSectionTimeSpace)
        return;
    
    [_models removeObjectAtIndex:index + 1];
    
    [_tableNode performBatchUpdates:^{
        [_tableNode deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:0]]
                          withRowAnimation:YES];
    } completion:nil];
}

#pragma mark - PhotoMessageCellNodeDelegate

- (void)photoMessageCellNode:(PhotoMessageCellNode *)cellNode
        didLoadImageWithSize:(CGSize)imageSize {
    if (cellNode && [cellNode isFinishLoadImage]) {
        [cellNode getMessage].imageRatio = imageSize.width / imageSize.height;
        [_loadedImageMessages addObject:[cellNode getMessage]];
        [_tableNode relayoutItems];
    }
}

@end
