//
//  ContactTableNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactTableNode.h"
#import "ContactTableCellNode.h"
#import "AppConsts.h"

@interface ContactTableNode () <ASTableDelegate, ASTableDataSource, ContactTableCellNodeDelegate>

@property (nonatomic, strong) ASTableNode *tableNode;

@property (nonatomic, strong) NSArray<ContactTableViewModel *> *viewModels;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionsArray;

@end

@implementation ContactTableNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
        _tableNode.dataSource = self;
        _tableNode.delegate = self;
        
        _viewModels = [[NSArray alloc] init];
        _sectionsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
            [_sectionsArray addObject:[NSMutableArray new]];
        }
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
}

#pragma mark - PublicMethods

- (void)setViewModels:(NSArray<ContactTableViewModel *> *)viewModels {
    _viewModels = [NSArray arrayWithArray:viewModels];
    [self fitPickerModelsData:_viewModels
                   toSections:_sectionsArray];
}

#pragma mark - SetData

- (void)fitPickerModelsData:(NSArray<ContactTableViewModel*> *)models
                 toSections:(NSMutableArray<NSMutableArray*> *)sectionsArray {
#if DEBUG
    assert(sectionsArray);
    assert(sectionsArray.count == ALPHABET_SECTIONS_NUMBER);
#endif
    
    if (!models)
        return;
    if (!sectionsArray)
        return;
    
    for (int i = 0; i < sectionsArray.count; i++) {
        [sectionsArray[i] removeAllObjects];
    }
    
    for (int i = 0; i < models.count; i++) {
        NSInteger index = [models[i] getSectionIndex];
        
        if (index >= 0 && index < ALPHABET_SECTIONS_NUMBER - 1) {
            [sectionsArray[index] addObject:models[i]];
        } else {
            [sectionsArray[ALPHABET_SECTIONS_NUMBER - 1] addObject:models[i]];
        }
    }
}

- (void)reloadData {
    [self.tableNode reloadData];
}

#pragma mark - ASTableDataSource

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return ALPHABET_SECTIONS_NUMBER;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode
 numberOfRowsInSection:(NSInteger)section {
    if (self.sectionsArray.count == 0)
        return 0;
    
    if (self.sectionsArray[section])
        return self.sectionsArray[section].count;
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    char sectionNameChar = section + FIRST_ALPHABET_ASCII_CODE;
    
    if (section == ALPHABET_SECTIONS_NUMBER - 1)
        return @"#";
    
    return [NSString stringWithFormat:@"%c", sectionNameChar].uppercaseString;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode
  nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.sectionsArray.count)
        return nil;
    if (indexPath.row >= self.sectionsArray[indexPath.section].count)
        return nil;
    
    ContactTableViewModel *model = self.sectionsArray[indexPath.section][indexPath.row];
    
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode *() {
        ContactTableCellNode *cellNode = [[ContactTableCellNode alloc] init];
        [cellNode setName:model.name];
        [cellNode setGradientColorBackground:model.gradientColorCode];
        [cellNode setSelectionStyle:UITableViewCellSelectionStyleNone];
        cellNode.delegate = self;
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(contactTableNode:loadImageToCellNode:atIndexPath:)]) {
            [self.delegate contactTableNode:self
                        loadImageToCellNode:cellNode
                                atIndexPath:indexPath];
        }
        
        return cellNode;
    };
    
    return ASCellNodeBlock;
}

#pragma mark - ASTableDelegate

// We handle this event manualy by PickerTableCellNodeDelegate, this method can't be called
- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    float avatarImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
    return ASSizeRangeMake(CGSizeMake(self.tableNode.frame.size.width, avatarImageHeight + 20));
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return SECTION_HEADER_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view
                                                      forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

- (void)tableNode:(ASTableNode *)tableNode didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableCellNode *cell = [tableNode nodeForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.25 animations:^{
        [cell setBackgroundColor:[UIColor colorWithRed:235/255.f
                                                 green:245/255.f
                                                  blue:251/255.f
                                                 alpha:1]];
    }];
}

- (void)tableNode:(ASTableNode *)tableNode didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableCellNode *cell = [tableNode nodeForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - ContactTableCellNodeDelegate

- (void)didSelectCellNode:(ContactTableCellNode *)cellNode {
    if (!cellNode)
        return;
    
    NSIndexPath *indexPath = [self.tableNode indexPathForNode:cellNode];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(contactTableNode:didSelectCellAtIndexPath:)]) {
        [self.delegate contactTableNode:self
               didSelectCellAtIndexPath:indexPath];
    }
}

@end
