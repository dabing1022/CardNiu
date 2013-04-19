//
//  ProfileScene.m
//  NiuNiu
//
//  Created by childhood on 13-4-18.
//
//

#import "ProfilePanel.h"
#import "User.h"

@implementation ProfilePanel

+ (id)profileWithUser:(User *)user
{
    return [[[self alloc]initWithUserData:user]autorelease];
}

- (id)initWithUserData:(User *)user
{
    if((self=[super init]))
    {
        _user = [user retain];
        CCLayerColor *bg = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 64)];
        CCSprite *avatar = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"avatar%@.png",user.avatarID]];
        CCLabelTTF *userName = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"userName:%@",user.userName]
                                                  fontName:@"Arial"
                                                  fontSize:12];
        CCLabelTTF *nickName = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"nickName:%@",user.nickName]
                                                  fontName:@"Arial"
                                                  fontSize:12];
        CCLabelTTF *coinYL = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"coinYL:%u",user.coinYL]
                                                fontName:@"Arial"
                                                fontSize:12];
        CCLabelTTF *coinTB = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"coinTB:%u",user.coinTB]
                                                fontName:@"Arial"
                                                fontSize:12];
        CCLabelTTF *roleID = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"roleID:%u",user.roleID]
                                                fontName:@"Arial"
                                                fontSize:12];
        CCLabelTTF *roleTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"roleTitle:%@",user.roleTitle]
                                                   fontName:@"Arial"
                                                   fontSize:12];
        CCLabelTTF *gamblerTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"gamblerTitle:%@",user.gamblerTitle]
                                                      fontName:@"Arial"
                                                      fontSize:12];
        CCLabelTTF *familyPropertyTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"familyPropertyTitle:%@",user.familyPropertyTitle]
                                                             fontName:@"Arial"
                                                             fontSize:12];
        CCLabelTTF *cardTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"cardTitle:%@",user.cardTitle]
                                                   fontName:@"Arial"
                                                   fontSize:12];
        CCLabelTTF *familyPropertyValue = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"familyPropertyValue:%u",user.familyPropertyValue]
                                                             fontName:@"Arial"
                                                             fontSize:12];
        
        CGSize size = [[CCDirector sharedDirector]winSize];
        [self addChild:bg];
        [self addChild:avatar];
        [self addChild:userName];
        [self addChild:nickName];
        [self addChild:coinYL];
        [self addChild:coinTB];
        [self addChild:roleID];
        [self addChild:roleTitle];
        [self addChild:gamblerTitle];
        [self addChild:familyPropertyTitle];
        [self addChild:cardTitle];
        [self addChild:familyPropertyValue];
        avatar.position = ccp(size.width/2, 450);
        userName.position = ccp(size.width/2, 420);
        nickName.position = ccp(size.width/2, 390);
        coinYL.position = ccp(size.width/2, 360);
        coinTB.position = ccp(size.width/2, 330);
        roleID.position = ccp(size.width/2, 300);
        roleTitle.position = ccp(size.width/2, 270);
        gamblerTitle.position = ccp(size.width/2, 240);
        familyPropertyTitle.position = ccp(size.width/2, 210);
        cardTitle.position = ccp(size.width/2, 180);
        familyPropertyValue.position = ccp(size.width/2, 150);
    }
    return self;
}

- (void)onEnter
{
    [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
    CCLOG(@"ProfilePanel onEnter");
}

- (void)onExit
{
    [[[CCDirector sharedDirector]touchDispatcher]removeDelegate:self];
    [super onExit];
    CCLOG(@"ProfilePanel onExit");
}

#pragma mark - TouchDelegate
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"关闭玩家详细信息面板");
    [self removeFromParentAndCleanup:YES];
}


- (void)dealloc
{
    [_user release];
    [super dealloc];
}
@end
