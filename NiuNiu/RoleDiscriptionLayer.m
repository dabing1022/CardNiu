//
//  RoleDiscriptionLayer.m
//  NiuNiu
//
//  Created by childhood on 13-4-12.
//
//

#import "RoleDiscriptionLayer.h"

@implementation RoleDiscriptionLayer
@synthesize roleId=_roleId;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	RoleDiscriptionLayer *layer = [RoleDiscriptionLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
+ (id)initWithRoleId:(int)roleId
{
    return [[[self alloc] initWithRoleId:roleId]autorelease];
}

- (id)initWithRoleId:(int)roleId
{
    if((self=[super initWithColor:ccc4(0, 0, 0, 100)]))
    {
        _roleId = roleId;
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"角色" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
		[self addChild: label];

        self.isTouchEnabled = YES;
    }
    return self;
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"RoleDiscriptionLayer touch begin");
    [self removeFromParentAndCleanup:YES];
}

- (void)onExit
{
    [super onExit];
}

- (void)dealloc
{
    
    [super dealloc];
    CCLOG(@"%s-->%@", __FILE__, NSStringFromSelector(_cmd));
}
@end
