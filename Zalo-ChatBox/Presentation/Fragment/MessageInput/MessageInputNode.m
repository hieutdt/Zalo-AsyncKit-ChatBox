//
//  MessageInputNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageInputNode.h"

static const int kFontSize = 22;

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
        _editTextNode.backgroundColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:1];
        _editTextNode.cornerRadius = 15;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kFontSize],
                                          NSParagraphStyleAttributeName : paragraphStyle,
                                          NSForegroundColorAttributeName: [UIColor grayColor]
        };
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Aa"
                                                                     attributes:attributedText];
        _editTextNode.attributedPlaceholderText = string;
        
        _sendButton = [[ASButtonNode alloc] init];
        _sendButton.backgroundColor = [UIColor clearColor];
        [_sendButton.backgroundImageNode setImage:[UIImage imageNamed:@"send"]];
    }
    return self;
}

- (void)didLoad {
    [super didLoad];
    
    _editTextNode.textView.font = [UIFont systemFontOfSize:kFontSize];
    _editTextNode.textView.layer.cornerRadius = 20;
    _editTextNode.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    
    _editTextNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - 60, maxConstrainedSize.height);
    _sendButton.style.preferredSize = CGSizeMake(35, 35);
    
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                                           spacing:10
                                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[_editTextNode, _sendButton]];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 10, 5, 10) child:stackSpec];
}

- (void)endEditing {
    [_editTextNode.textView endEditing:YES];
}

@end
