//
//  MessageTableNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageTableNode.h"
#import "MessageCellNode.h"
#import "AppConsts.h"
#import "LayoutHelper.h"

static const int kFontSize = 18;
static const int kTimeFontSize = 15;
static NSString *kFontName = @"HelveticaNeue";

@interface MessageTableNode () <ASTableDelegate, ASTableDataSource>

@property (nonatomic, strong) NSArray<Message *> *messages;
@property (nonatomic, strong) NSMutableArray<Message *> *models;
@property (nonatomic, strong) NSMutableArray<NSString *> *sectionTitles;

@property (nonatomic, strong) ASTableNode *tableNode;

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
        
        _models = [[NSMutableArray alloc] init];
        _sectionTitles = [[NSMutableArray alloc] init];
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
    _messages = sortedArray;
}

- (void)generateSectionData {
    if (!_messages)
        return;
    if (_messages.count == 0)
        return;
    
    NSMutableArray *cellModels = [[NSMutableArray alloc] init];
    [cellModels addObject:[[Message alloc] initWithMessage:@"" from:@"" to:@""
                                                 timestamp:_messages[0].timestamp
                                                     style:MessageStyleSection]];
    [cellModels addObject:_messages[0]];
    
    for (int i = 1; i < _messages.count; i++) {
        if (_messages[i].timestamp - _messages[i - 1].timestamp >= kMessageSectionTimeSpace) {
            [cellModels addObject:[[Message alloc] initWithMessage:@"" from:@"" to:@""
                                                         timestamp:_messages[i].timestamp
                                                             style:MessageStyleSection]];
        }
        
        [cellModels addObject:_messages[i]];
    }
    
    _models = cellModels;
}


#pragma mark - PublicMethods

- (void)setMessages:(NSArray<Message *> *)messages {
    if (messages) {
        _messages = [NSMutableArray arrayWithArray:messages];
        [self sortNeareastTimeFirst];
        [self generateSectionData];
    }
}

- (void)reloadData {
    [_tableNode reloadData];
}

- (void)scrollToBottom {
    [_tableNode scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_models.count - 1
                                                          inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:NO];
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
    ASCellNode *(^cellNodeBlock)(void) = ^ASCellNode *() {
        MessageCellNode *cellNode = [[MessageCellNode alloc] init];
        [cellNode setMessage:mess];
        cellNode.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cellNode;
    };
    
    return cellNodeBlock;
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.models.count)
        return ASSizeRangeZero;
    
    Message *mess = self.models[indexPath.item];
    NSString *text = mess.message;
    
    CGSize size = CGSizeMake(self.view.frame.size.width * 0.7, 1000);
    CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:text
                                                          font:[UIFont fontWithName:kFontName size:kFontSize]
                                                   parrentSize:size];
    
    return ASSizeRangeMake(CGSizeMake(estimatedFrame.size.width + 10, estimatedFrame.size.height + 20));
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_HEADER_HEIGHT)];
//    headerLabel.textAlignment = NSTextAlignmentCenter;
//    headerLabel.textColor = [UIColor grayColor];
//    headerLabel.font = [UIFont fontWithName:kFontName size:kTimeFontSize];
//
//    Message *firstMessOfSection =  (Message *)[_messageSections[section] firstObject];
//    NSTimeInterval tsForSection = firstMessOfSection.timestamp;
//
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:tsForSection];
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    formatter.timeZone = [NSTimeZone localTimeZone];
//
//    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
//        formatter.dateFormat = @"HH:mm 'Hôm nay'";
//    } else if ([[NSCalendar currentCalendar] isDateInYesterday:date]) {
//        formatter.dateFormat = @"HH:mm 'Hôm qua'";
//    } else {
//        formatter.dateFormat = @"HH:mm dd/MM/YYYY";
//    }
//
//    [headerLabel setText:[formatter stringFromDate:date]];
//    headerLabel.transform = CGAffineTransformScale(headerLabel.transform, 1, -1);
//
//    return headerLabel;
//}


#pragma mark - ASTableDelegate


@end
