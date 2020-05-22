//
//  MessageInputNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageInputNode.h"

@interface MessageInputNode ()

@property (nonatomic, strong) ASEditableTextNode *editTextNode;
@property (nonatomic, strong) ASButtonNode *sendButton;

@end

@implementation MessageInputNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        _editTextNode = [[ASEditableTextNode alloc] init];
        _editTextNode.backgroundColor = [UIColor whiteColor];
        _sendButton = [[ASButtonNode alloc] init];
        _sendButton.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _editTextNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - 100, maxConstrainedSize.height);
    _sendButton.style.preferredSize = CGSizeMake(40, 40);
    
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                                           spacing:10
                                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[_editTextNode, _sendButton]];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 5, 5, 5) child:stackSpec];
}

@end
