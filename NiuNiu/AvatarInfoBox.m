//
//  AvatarInfoBox.m
//  NiuNiu
//  CardPlayingScene中玩家头像信息盒子
//  Created by childhood on 13-4-18.
//
//

#import "AvatarInfoBox.h"
#import "GCDAsyncSocketHelper.h"
#import "GameData.h"
@implementation AvatarInfoBox


#pragma mark - init
+ (CCSprite *)infoBoxWithUserData:(User *)user
{
    return [[[self alloc]initInfoBoxWithUserData:user]autorelease];
}
- (id)initInfoBoxWithUserData:(User *)user
{
    if((self = [super init]))
    {
        _user = [user retain];
        _avatarSpr = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"avatar%@.png",user.avatarID]];
        [self addChild:_avatarSpr z:0 tag:kTagAvatarSpr];
        _coinTB = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",user.coinTB] fontName:@"Arial" fontSize:24];
        _coinTB.position = ccp(50, 8);
        [self addChild:_coinTB z:1 tag:kTagCoinTB];
    }
    return self;
}

- (void)updateCoinTB:(int)coinTB
{
    [_coinTB setString:[NSString stringWithFormat:@"%d",coinTB]];
}

- (void)onEnter
{
    [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit
{
    [[[CCDirector sharedDirector]touchDispatcher]removeDelegate:self];
    [super onExit];
}

#pragma mark - TouchDelegate
- (BOOL)containsTouchLocation:(UITouch *)touch
{
    return CGRectContainsPoint([self rect], [self convertTouchToNodeSpaceAR:touch]);
}

- (CGRect)rect
{
    CGSize size = _avatarSpr.contentSize;
    CGRect rect = CGRectMake(-size.width/2, -size.height/2, size.width, size.height);
    return rect;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(![self containsTouchLocation:touch])
        return NO;
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"点击头像,向服务器请求详细数据");
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[GameData sharedGameData]player].userID,@"userID",_user.userID,@"targetUserID",nil];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_VIEW_PROFILE contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:0 socketType:CARD_SOCKET];
}

- (void)dealloc
{
    [_user release];
    [super dealloc];
}
@end
