//
//  ChatBoxViewController.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ChatBoxViewController.h"

#import "MessageTableNode.h"
#import "AppConsts.h"

@interface ChatBoxViewController ()

@property (nonatomic, strong) ASDisplayNode *contentNode;
@property (nonatomic, strong) MessageTableNode *tableNode;

@property (nonatomic, strong) NSMutableArray<Message *> *messages;

@end

@implementation ChatBoxViewController

- (instancetype)init {
    _contentNode = [[ASDisplayNode alloc] init];
    self = [super initWithNode:_contentNode];
    if (self) {
        __weak ChatBoxViewController *weakSelf = self;
        
        _tableNode = [[MessageTableNode alloc] init];
        _messages = [[NSMutableArray alloc] init];
        
        _contentNode.automaticallyManagesSubnodes = YES;
        [_contentNode setBackgroundColor:[UIColor systemBlueColor]];
        _contentNode.layoutSpecBlock = ^ASLayoutSpec *(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            weakSelf.tableNode.style.preferredSize = constrainedSize.max;
            weakSelf.tableNode.backgroundColor = [UIColor whiteColor];
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                          child:weakSelf.tableNode];
        };
        [_contentNode layoutSpecBlock];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [_tableNode setMessages:_messages];
    [_tableNode reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initData {
    [_messages addObject:[[Message alloc] initWithMessage:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris convallis metus at vestibulum tempus. Fusce mi arcu, commodo quis consectetur eget, commodo id magna."
                                                     from:kCurrentUser
                                                       to:_messageToContact.phoneNumber
                                                timestamp:1589857194
                                                    style:MessageStyleText]];
    
    [_messages addObject:[[Message alloc] initWithMessage:@"Fusce aliquam ut diam ac faucibus. Nullam augue urna, vestibulum imperdiet sapien eget, ultrices facilisis nibh. Nam pellentesque, ante eget accumsan sagittis, elit urna imperdiet lorem, ac fermentum nisi elit consequat ante. Vestibulum volutpat scelerisque felis, id malesuada eros varius in. Aenean sapien nisl, finibus ut porta sit amet, pellentesque vel nisi. Curabitur dictum quam in lacus placerat ultrices."
                                                     from:_messageToContact.phoneNumber
                                                       to:kCurrentUser
                                                timestamp:1589857347
                                                    style:MessageStyleText]];
    
    [_messages addObject:[[Message alloc] initWithMessage:@"Quisque et nibh ac ante convallis luctus. "
                                                     from:kCurrentUser
                                                       to:_messageToContact.phoneNumber
                                                timestamp:1589857408
                                                    style:MessageStyleText]];
    
    [_messages addObject:[[Message alloc] initWithMessage:@"Mauris dui lectus, sagittis vel interdum non, varius nec risus. Mauris porta urna sed nulla imperdiet sodales. Mauris vel tempor eros, eget rutrum dolor. Fusce tempor ipsum id sem convallis gravida. Donec tincidunt feugiat purus, et efficitur nisi rhoncus quis. Mauris sapien sem, aliquet vel tempor sit amet, lobortis vel dui."
                                                     from:kCurrentUser
                                                       to:_messageToContact.phoneNumber
                                                timestamp:1589875466
                                                    style:MessageStyleText]];
    
    [_messages addObject:[[Message alloc] initWithMessage:@"Aenean."
                                                     from:_messageToContact.phoneNumber
                                                       to:kCurrentUser
                                                timestamp:1589875520
                                                    style:MessageStyleText]];
    
    [_messages addObject:[[Message alloc] initWithMessage:@"Vivamus efficitur orci id neque blandit, vitae dignissim nulla tincidunt. Sed accumsan, tortor id commodo tempus, risus turpis sodales ex, ut pellentesque lectus odio eget nisi. Fusce vitae tortor congue, imperdiet mauris eu, vulputate ipsum. Integer sed vulputate enim, non dignissim erat. Duis sed dignissim mi. Fusce in ultrices nulla. Duis facilisis auctor nulla in tincidunt.."
                                                     from:_messageToContact.phoneNumber
                                                       to:kCurrentUser
                                                timestamp:1589875631
                                                    style:MessageStyleText]];
}


@end
