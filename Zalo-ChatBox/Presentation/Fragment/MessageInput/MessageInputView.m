//
//  MessageInputView.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/29/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageInputView.h"
#import "LayoutHelper.h"

static const NSUInteger editTextBoxHeight = 40;
static const NSUInteger maxEditTextBoxHeight = 250;

@interface MessageInputView () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIView *textInputContainer;
@property (weak, nonatomic) IBOutlet UITextView *textInput;
@property (weak, nonatomic) IBOutlet UIButton *emojiButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editTextContainerHeight;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, assign) BOOL editing;

@end

@implementation MessageInputView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _initialFrame = frame;
        [self customInit];
    }
    return self;
}

- (void)customInit {
    UINib *nib = [UINib nibWithNibName:@"MessageInputView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    
    _contentView.frame = self.bounds;
    
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_contentView];
    
    [_contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [_contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor constant:-5].active = YES;
    
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.alpha = 0.9;
    
    _textInputContainer.backgroundColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:1];
    _textInputContainer.layer.masksToBounds = YES;
    _textInputContainer.layer.cornerRadius = 15;
    
    _textInput.delegate = self;
    _textInput.text = @"Aa";
    _textInput.textColor = [UIColor lightGrayColor];
    _textInput.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    
    _editing = NO;
}

- (void)endEditingWithKeepText:(BOOL)keepText; {
    if (!keepText || _textInput.text.length == 0) {
        _textInput.text = @"Aa";
        _textInput.textColor = [UIColor lightGrayColor];
    }
    
    [self.textInput endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewDidBeginEditing:)]) {
        [self.delegate messageInputViewDidBeginEditing:self];
    }
    
    _editing = YES;
    
    if ([_textInput.text isEqualToString:@"Aa"]) {
        _textInput.text = @"";
        _textInput.textColor = [UIColor darkTextColor];
    }
    
    __weak MessageInputView *weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        [weakSelf.moreButton setImage:[UIImage imageNamed:@"collapseBtn"] forState:UIControlStateNormal];
        [weakSelf.sendButton setImage:[UIImage imageNamed:@"sendBtn"] forState:UIControlStateNormal];
        
        weakSelf.cameraButton.hidden = YES;
        weakSelf.imageButton.hidden = YES;
        weakSelf.voiceButton.hidden = YES;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewDidEndEditing:)]) {
        [self.delegate messageInputViewDidEndEditing:self];
    }
    
    _editing = NO;
    
    __weak MessageInputView *weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf.moreButton setImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateNormal];
        [weakSelf.sendButton setImage:[UIImage imageNamed:@"likeFilledBtn"] forState:UIControlStateNormal];
        
        weakSelf.cameraButton.hidden = NO;
        weakSelf.imageButton.hidden = NO;
        weakSelf.voiceButton.hidden = NO;
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = textView.text;
    CGSize boundingSize = CGSizeMake(textView.frame.size.width, 500);
    CGRect estimatedFrame = [LayoutHelper estimatedFrameOfText:text
                                                          font:[UIFont fontWithName:@"HelveticaNeue" size:18]
                                                   parrentSize:boundingSize];
    
    CGSize estimatedSize = estimatedFrame.size;
    if (estimatedSize.height > editTextBoxHeight && estimatedSize.height <= editTextBoxHeight * 2) {
        _editTextContainerHeight.constant = editTextBoxHeight * 2;
        self.frame = CGRectMake(_initialFrame.origin.x, _initialFrame.origin.y - 30, _initialFrame.size.width, _initialFrame.size.height + 30);
        
        
    } else if (estimatedSize.height > editTextBoxHeight * 2) {
        _editTextContainerHeight.constant = maxEditTextBoxHeight;
        self.frame = CGRectMake(_initialFrame.origin.x, _initialFrame.origin.y - 50, _initialFrame.size.width, _initialFrame.size.height + 50);
        
    } else {
        _editTextContainerHeight.constant = editTextBoxHeight;
        self.frame = self.initialFrame;
    }
}

#pragma mark - Actions

- (IBAction)moreButtonTapped:(id)sender {
    if (_editing) {
        [self endEditingWithKeepText:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewCollapseButtonTapped:)]) {
            [self.delegate messageInputViewCollapseButtonTapped:self];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewSendSticker:)]) {
            [self.delegate messageInputViewSendSticker:self];
        }
    }
}

- (IBAction)sendButtonTapped:(id)sender {
    if (self.editing) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewSendButtonTapped:withMessageText:)]) {
            [self.delegate messageInputViewSendButtonTapped:self withMessageText:_textInput.text];
        }
        
        _textInput.text = @"";
        
        self.frame = self.initialFrame;
        self.editTextContainerHeight.constant = editTextBoxHeight;
        
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewSendLike:)]) {
            [self.delegate messageInputViewSendLike:self];
        }
    }
}

@end
