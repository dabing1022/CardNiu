//
//  ProfileScene.m
//  NiuNiu
//
//  Created by childhood on 13-4-18.
//
//

#import "ProfileScene.h"
#import "User.h"

@implementation ProfileScene


+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];	
	ProfileScene *layer = [ProfileScene node];
	[scene addChild: layer];
	return scene;
}

+ (id)profileWithUser:(User *)user
{
    return [[[self alloc]initWithUserData:user]autorelease];
}

- (id)initWithUserData:(User *)user
{
    if((self=[super initWithColor:ccc4(0, 0, 0, 64)]))
    {
        CCSprite *avatar = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"avatar%@.png",user.avatarID]];
        CCLabelTTF *userName = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"userName:%@",user.userName]
                                                  fontName:@"Arial"
                                                  fontSize:24];
        CCLabelTTF *nickName = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"nickName:%@",user.nickName]
                                                  fontName:@"Arial"
                                                  fontSize:24];
        CCLabelTTF *coinYL = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"coinYL:%u",user.coinYL]
                                                  fontName:@"Arial"
                                                  fontSize:24];
        CCLabelTTF *coinTB = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"coinTB:%u",user.coinTB]
                                                  fontName:@"Arial"
                                                  fontSize:24];
        CCLabelTTF *roleID = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"roleID:%u",user.roleID]
                                                fontName:@"Arial"
                                                fontSize:24];
        CCLabelTTF *roleTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"roleTitle:%@",user.roleTitle]
                                                fontName:@"Arial"
                                                fontSize:24];
        CCLabelTTF *gamblerTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"gamblerTitle:%@",user.gamblerTitle]
                                                fontName:@"Arial"
                                                fontSize:24];
        CCLabelTTF *familyPropertyTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"familyPropertyTitle:%@",user.familyPropertyTitle]
                                                fontName:@"Arial"
                                                fontSize:24];
        CCLabelTTF *cardTitle = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"cardTitle:%@",user.cardTitle]
                                                fontName:@"Arial"
                                                fontSize:24];
        CCLabelTTF *familyPropertyValue = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"familyPropertyValue:%u",user.familyPropertyValue]
                                                fontName:@"Arial"
                                                fontSize:24];
        
        CGSize size = [[CCDirector sharedDirector]winSize];
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
        
        self.isTouchEnabled = YES;
    }
    return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"ProfileScene.h-->ccTouchesBegan");
}
@end
