//
//  MessageInputView.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/29/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageInputView.h"

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
        [self customInit];
    }
    return self;
}

- (void)customInit {
    UINib *nib = [UINib nibWithNibName:@"MessageInputView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    
    _contentView.frame = self.bounds;
    [self addSubview:_contentView];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.alpha = 0.9;
    
    _textInputContainer.backgroundColor = [UIColor colorWithRed:229/255.f green:231/255.f blue:233/255.f alpha:1];
    _textInputContainer.layer.masksToBounds = YES;
    _textInputContainer.layer.cornerRadius = 15;
    
    _textInput.delegate = self;
    _textInput.text = @"Aa";
    _textInput.textColor = [UIColor lightGrayColor];
    
    _editing = NO;
}

- (void)endEditing {
    [self.textInput endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewDidBeginEditing:)]) {
        [self.delegate messageInputViewDidBeginEditing:self];
    }
    
    _editing = YES;
    
    _textInput.text = @"";
    _textInput.textColor = [UIColor darkTextColor];
    
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
    
    _textInput.text = @"Aa";
    _textInput.textColor = [UIColor lightGrayColor];
    
    __weak MessageInputView *weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf.moreButton setImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateNormal];
        [weakSelf.sendButton setImage:[UIImage imageNamed:@"likeFilledBtn"] forState:UIControlStateNormal];
        
        weakSelf.cameraButton.hidden = NO;
        weakSelf.imageButton.hidden = NO;
        weakSelf.voiceButton.hidden = NO;
    }];
}

#pragma mark - Actions

- (IBAction)moreButtonTapped:(id)sender {
    if (_editing) {
        [self endEditing];
    } else {
        // Show more
        
    }
}
- (IBAction)sendButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputViewSendButtonTapped:withMessageText:)]) {
        [self.delegate messageInputViewSendButtonTapped:self withMessageText:_textInput.text];
    }
    
    _textInput.text = @"";
}

@end
