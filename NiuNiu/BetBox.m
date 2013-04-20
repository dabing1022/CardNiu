//
//  BetBox.m
//  NiuNiu
//
//  Created by childhood on 13-4-20.
//
//

#import "BetBox.h"
#import "GCDAsyncSocketHelper.h"
#import "Game.h"

@implementation BetBox


#pragma mark - init
+ (id)betBoxWithRatio:(int)ratio status:(BOOL)state
{
    return [[[self alloc]initWithRatio:ratio status:state]autorelease];
}

- (id)initWithRatio:(int)ratio status:(BOOL)state

{
    if((self = [super init]))
    {
        _ratio = ratio;
        _state = state;
        if(state){
            _bg = [CCSprite spriteWithFile:@"betBoxBg.png"];
        }else{
            _bg = [CCSprite spriteWithFile:@"betBoxBgDisabled.png"];
        }
        [self addChild:_bg];
        
        _ratioLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",ratio] fontName:@"Arial" fontSize:10];
        [self addChild:_ratioLabel];
        
    }
    return self;
}

- (void)onEnter
{
    if(_state)
        [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit
{
    if(_state)
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
    CGSize size = _bg.contentSize;
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
    NSDictionary *betChoice = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_ratio] forKey:@"ratio"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_START_BET contentDic:betChoice];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_START_BET socketType:CARD_SOCKET];
    
    //NSDictionary *dic = [NSDictionary dictionaryWithObject:self forKey:@"betBox"];
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"didChooseRatio" object:nil userInfo:dic];
    CCLOG(@"点击选择下注为：%d", _ratio);
}

- (void)dealloc
{
    [super dealloc];
}
@end
