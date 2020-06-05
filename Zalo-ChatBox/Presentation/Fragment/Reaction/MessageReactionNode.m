//
//  MessageReactionNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageReactionNode.h"

@interface MessageReactionNode ()

@property (nonatomic, strong) ASImageNode *likeReactImg;
@property (nonatomic, strong) ASImageNode *loveReactImg;
@property (nonatomic, strong) ASImageNode *hahaReactImg;
@property (nonatomic, strong) ASImageNode *wowReactImg;
@property (nonatomic, strong) ASImageNode *sadReactImg;
@property (nonatomic, strong) ASImageNode *angryReactImg;

@property (nonatomic, strong) NSArray<ASImageNode *> *reacts;

@end

@implementation MessageReactionNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        self.cornerRadius = 25;
        self.shadowColor = [UIColor blackColor].CGColor;
        self.shadowOpacity = 0.3;
        self.shadowRadius = 1.5;
        
        _likeReactImg = [[ASImageNode alloc] init];
        _likeReactImg.style.preferredSize = CGSizeMake(40, 40);
        _likeReactImg.contentMode = UIViewContentModeScaleToFill;
        [_likeReactImg setImage:[UIImage imageNamed:@"img_1"]];
        
        _loveReactImg = [[ASImageNode alloc] init];
        _loveReactImg.style.preferredSize = CGSizeMake(40, 40);
        _loveReactImg.contentMode = UIViewContentModeScaleToFill;
        [_loveReactImg setImage:[UIImage imageNamed:@"img_2"]];
        
        _hahaReactImg = [[ASImageNode alloc] init];
        _hahaReactImg.style.preferredSize = CGSizeMake(40, 40);
        _hahaReactImg.contentMode = UIViewContentModeScaleToFill;
        [_hahaReactImg setImage:[UIImage imageNamed:@"img_3"]];
        
        _wowReactImg = [[ASImageNode alloc] init];
        _wowReactImg.style.preferredSize = CGSizeMake(40, 40);
        _wowReactImg.contentMode = UIViewContentModeScaleToFill;
        [_wowReactImg setImage:[UIImage imageNamed:@"img_4"]];
        
        _sadReactImg = [[ASImageNode alloc] init];
        _sadReactImg.style.preferredSize = CGSizeMake(40, 40);
        _sadReactImg.contentMode = UIViewContentModeScaleToFill;
        [_sadReactImg setImage:[UIImage imageNamed:@"img_5"]];
        
        _angryReactImg = [[ASImageNode alloc] init];
        _angryReactImg.style.preferredSize = CGSizeMake(40, 40);
        _angryReactImg.contentMode = UIViewContentModeScaleToFill;
        [_angryReactImg setImage:[UIImage imageNamed:@"img_6"]];
        
        _reacts = @[_likeReactImg, _loveReactImg, _hahaReactImg, _wowReactImg, _sadReactImg, _angryReactImg];
        
        
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    ASStackLayoutSpec *mainStack = [ASStackLayoutSpec
                                    stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                    spacing:10
                                    justifyContent:ASStackLayoutJustifyContentCenter
                                    alignItems:ASStackLayoutAlignItemsCenter
                                    children:@[_likeReactImg, _loveReactImg, _hahaReactImg, _wowReactImg, _sadReactImg, _angryReactImg]];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)
                                                  child:mainStack];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches.allObjects lastObject];
    CGPoint position = [touch locationInView:self.view];
    
    NSInteger index = -1;
    for (int i = 0; i < 6; i++) {
        if (position.x <= 10 * (i + 2) + (i + 1) * 40) {
            index = i;
            break;
        }
    }
    
    if (index < 0 || index >= self.reacts.count)
        return;
    
    ASImageNode *focusNode = self.reacts[index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageReactionNode:didSelectReactionType:)]) {
        [self.delegate messageReactionNode:self didSelectReactionType:index + 1];
    }
}

@end
