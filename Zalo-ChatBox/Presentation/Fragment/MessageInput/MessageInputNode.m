//
//  MessageInputNode.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageInputNode.h"

static const int kFontSize = 22;
static const CGFloat kButtonSize = 25;
static const CGFloat kSpace = 10;

@interface MessageInputNode () <ASEditableTextNodeDelegate>

@property (nonatomic, strong) ASButtonNode *moreButton;
@property (nonatomic, strong) ASButtonNode *cameraButton;
@property (nonatomic, strong) ASButtonNode *imageButton;
@property (nonatomic, strong) ASButtonNode *voiceButton;

@property (nonatomic, strong) ASDisplayNode *editTextCotainerNode;
@property (nonatomic, strong) ASEditableTextNode *editTextNode;
@property (nonatomic, strong) ASButtonNode *emojiButton;

@property (nonatomic, strong) ASButtonNode *sendButton;

@property (nonatomic, assign) CGSize maxConstrainedSize;

@property (nonatomic, assign) BOOL typing;

@end

@implementation MessageInputNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        _moreButton = [[ASButtonNode alloc] init];
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateNormal];
        
        _cameraButton = [[ASButtonNode alloc] init];
        [_cameraButton setBackgroundImage:[UIImage imageNamed:@"cameraBtn"] forState:UIControlStateNormal];
        
        _imageButton = [[ASButtonNode alloc] init];
        [_imageButton setBackgroundImage:[UIImage imageNamed:@"imageBtn"] forState:UIControlStateNormal];
        
        _voiceButton = [[ASButtonNode alloc] init];
        [_voiceButton setBackgroundImage:[UIImage imageNamed:@"voiceBtn"] forState:UIControlStateNormal];
        
        _emojiButton = [[ASButtonNode alloc] init];
        [_emojiButton setBackgroundImage:[UIImage imageNamed:@"emojiBtn"] forState:UIControlStateNormal];
        
        _editTextCotainerNode = [[ASDisplayNode alloc] init];
        _editTextCotainerNode.backgroundColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:0.8];
        _editTextCotainerNode.cornerRadius = 15;
        
        _editTextNode = [[ASEditableTextNode alloc] init];
        _editTextNode.backgroundColor = [UIColor clearColor];
        _editTextNode.delegate = self;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:kFontSize],
                                          NSParagraphStyleAttributeName : paragraphStyle,
                                          NSForegroundColorAttributeName: [UIColor grayColor]
        };
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Aa"
                                                                     attributes:attributedText];
        [_editTextNode setAttributedPlaceholderText:string];
        [_editTextNode setPlaceholderEnabled:YES];
        
        _sendButton = [[ASButtonNode alloc] init];
        _sendButton.backgroundColor = [UIColor clearColor];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"sendBtn"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}

- (void)didLoad {
    [super didLoad];
    
    _editTextNode.textView.font = [UIFont systemFontOfSize:kFontSize];
    _editTextNode.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxConstrainedSize = constrainedSize.max;
    _maxConstrainedSize = maxConstrainedSize;
    
    _moreButton.style.preferredSize = CGSizeMake(kButtonSize, kButtonSize);
    _cameraButton.style.preferredSize = CGSizeMake(kButtonSize, kButtonSize);
    _imageButton.style.preferredSize = CGSizeMake(kButtonSize, kButtonSize);
    _voiceButton.style.preferredSize = CGSizeMake(kButtonSize, kButtonSize);
    _sendButton.style.preferredSize = CGSizeMake(kButtonSize, kButtonSize);
    _emojiButton.style.preferredSize = CGSizeMake(kButtonSize, kButtonSize);
    
    if (!self.typing) {
        _editTextCotainerNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - kButtonSize*5 - kSpace*5 - 15,
                                                               maxConstrainedSize.height - 5);
        _editTextNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - kButtonSize*6 - kSpace*5 - 27,
                                                       maxConstrainedSize.height - 5);
    } else {
        _editTextCotainerNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - kButtonSize*2 - kSpace*2 - 15,
                                                               maxConstrainedSize.height - 5);
        _editTextNode.style.preferredSize = CGSizeMake(maxConstrainedSize.width - kButtonSize *3 - kSpace * 2 - 27,
                                                       maxConstrainedSize.height - 5);
    }
    
    ASStackLayoutSpec *editTextStack = [ASStackLayoutSpec
                                        stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                        spacing:2
                                        justifyContent:ASStackLayoutJustifyContentStart
                                        alignItems:ASStackLayoutAlignItemsCenter
                                        children:@[_editTextNode, _emojiButton]];
    
    ASInsetLayoutSpec *textInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 5, 0, 5)
                                                                          child:editTextStack];
    
    ASOverlayLayoutSpec *overlayTextNode = [ASOverlayLayoutSpec
                                            overlayLayoutSpecWithChild:_editTextCotainerNode
                                            overlay:textInset];
    
    
    NSArray *childs = @[];
    if (self.typing) {
        childs = @[_moreButton, overlayTextNode, _sendButton];
    } else {
        childs = @[_moreButton, _cameraButton, _imageButton, _voiceButton, overlayTextNode, _sendButton];
    }
    
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec
                                    stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                    spacing:kSpace
                                    justifyContent:ASStackLayoutJustifyContentStart
                                    alignItems:ASStackLayoutAlignItemsCenter
                                    children:childs];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(5, 10, 5, 10) child:stackSpec];
}

- (void)endEditing {
    [_editTextNode.textView endEditing:YES];
    _typing = NO;
    [self setNeedsLayout];
}

#pragma mark - Action

- (void)sendButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:_editTextNode.textView.text];
        _editTextNode.textView.text = @"";
    }
}

#pragma mark - ASEditableTextNodeDelegate

- (void)editableTextNodeDidBeginEditing:(ASEditableTextNode *)editableTextNode {
    _typing = YES;
    [self setNeedsLayout];
}

@end
