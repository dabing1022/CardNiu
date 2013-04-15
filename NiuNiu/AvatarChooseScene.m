//
//  AvatarChooseScene.m
//  NiuNiu 头像选择场景
//
//  Created by childhood on 13-4-9.
//
//

#import "AvatarChooseScene.h"

#define TAG_AVATAR01 1
#define TAG_AVATAR02 2
#define TAG_AVATAR03 3
#define TAG_AVATAR04 4
#define TAG_AVATAR05 5

@implementation AvatarChooseScene


+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
	AvatarChooseScene *layer = [AvatarChooseScene node];
    [scene addChild: layer];
	return scene;
}

- (id)init
{
    if((self = [super initWithColor:ccc4(220, 249, 255, 255)]))
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sketchSpriteSheet.plist"];
        CCSpriteBatchNode *avatarSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sketchSpriteSheet.pvr.ccz"];
        [self addChild:avatarSpriteSheet];
        
        
        chooseAvatarTTF = [CCLabelTTF labelWithString:@"选择头像" fontName:@"Arial" fontSize:26];
        chooseAvatarTTF.color = ccc3(0, 0, 0);
        [chooseAvatarTTF setPosition:ccp(150, 400)];
        [self addChild:chooseAvatarTTF];
        
        CCMenuItemImage *avatar01 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"avatar01.png"]
                                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"avatar01.png"]
                                                                   target:self
                                                                 selector:@selector(chooseAvatar:)];
        [avatar01 setPosition:ccp(60, 300)];
        avatar01.tag = TAG_AVATAR01;
                
        CCMenuItemImage *avatar02 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"avatar02.png"]
                                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"avatar02.png"] target:self
                                                                 selector:@selector(chooseAvatar:)];
        [avatar02 setPosition:ccp(150, 300)];
        avatar02.tag = TAG_AVATAR02;
        
        CCMenuItemImage *avatar03 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"avatar03.png"]
                                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"avatar03.png"] target:self
                                                                 selector:@selector(chooseAvatar:)];
        [avatar03 setPosition:ccp(240, 300)];
        avatar03.tag = TAG_AVATAR03;
        
        CCMenuItemImage *avatar04 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"avatar04.png"]
                                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"avatar04.png"] target:self
                                                                 selector:@selector(chooseAvatar:)];
        [avatar04 setPosition:ccp(96, 205)];
        avatar04.tag = TAG_AVATAR04;
        
        CCMenuItemImage *avatar05 = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"avatar05.png"]
                                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"avatar05.png"] target:self
                                                                 selector:@selector(chooseAvatar:)];
        [avatar05 setPosition:ccp(196, 205)];
        avatar05.tag = TAG_AVATAR05;

        CCMenu *avatarMenu = [CCMenu menuWithItems:avatar01,avatar02,avatar03,avatar04,avatar05, nil];
        [avatarMenu setPosition:CGPointZero];
        [self addChild:avatarMenu];
        
        CCMenuItemImage *confirmMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"confirmNomal.png"]
                                                                  selectedSprite:[CCSprite spriteWithSpriteFrameName:@"confirmSelected.png"] target:self
                                                                        selector:@selector(confirmChoice:)];
        [confirmMenuItem setPosition:ccp(225, 56)];
        CCMenuItem *confirmMenu = [CCMenu menuWithItems:confirmMenuItem, nil];
        [confirmMenu setPosition:CGPointZero];
        [self addChild:confirmMenu];
    }
    return self;
}

- (void)chooseAvatar:(id)sender
{
    CCMenuItemImage *selectedAvatarImg = (CCMenuItemImage *)sender;
    switch (selectedAvatarImg.tag) {
        case TAG_AVATAR01:
            CCLOG(@"AVATAR01 CLICKED.");
            break;
        case TAG_AVATAR02:
            CCLOG(@"AVATAR02 CLICKED.");
            break;
        case TAG_AVATAR03:
            CCLOG(@"AVATAR03 CLICKED.");
            break;
        case TAG_AVATAR04:
            CCLOG(@"AVATAR04 CLICKED.");
            break;
        case TAG_AVATAR05:
            CCLOG(@"AVATAR05 CLICKED.");
            break;
        default:
            break;
    }
}

- (void)confirmChoice:(id)sender
{
    CCLOG(@"confirm choice");
}

-(void)dealloc
{  
    [super dealloc];
}

@end
