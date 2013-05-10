//
//  PopUpTipView.m
//  NiuNiu
//
//  Created by childhood on 13-5-8.
//
//

#import "PopUpTipView.h"

@implementation PopUpTipView
@synthesize scale9spr=_scale9Spr,type=_type,tipTxt=_tipTxt;
static NSArray *_tipTypeArr;



+ (id)viewWithType:(int)type
{
    return [[[self alloc]initWithType:type]autorelease];
}

- (id)initWithType:(int)type
{
    if((self = [super initWithColor:ccc4(0, 0, 0, 150)])){
        _tipTypeArr = [NSArray arrayWithObjects:@"正在分配房间请稍后",
                                                @"连接服务器中·····",
                                                @"重连服务器中······",nil];
        
        self.scale9spr = [CCScale9Sprite spriteWithSpriteFrameName:@"tipRoundRectBg1.png"];
        [self addChild:_scale9Spr];
        CGSize size = [[CCDirector sharedDirector]winSize];
        [_scale9Spr setPosition:CGPointMake(size.width/2 - _scale9Spr.boundingBox.size.width/2, size.height/2 - _scale9Spr.boundingBox.size.height/2 - 10)];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.center = ccp(size.width/2, size.height/2);
        
        self.tipTxt = [CCLabelTTF labelWithString:[_tipTypeArr objectAtIndex:type] fontName:@"Arial" fontSize:12];
        [self addChild:_tipTxt];
        [_tipTxt setPosition:CGPointMake(size.width/2, size.height/2 - 20)];
        
        if(type == kTipType_CONNECT_CARD_SERVER){
            [self setOpacity:0.0f];
        }
        
    }
    return self;
}

- (void)onEnter
{
    [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
    [[[CCDirector sharedDirector] view] addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    [super onEnter];
}

- (void)onExit
{
    [[[CCDirector sharedDirector]touchDispatcher]removeDelegate:self];
    
    [_activityIndicatorView stopAnimating];
    [_activityIndicatorView removeFromSuperview];
    [super onExit];
}

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    return [[CCDirector sharedDirector]convertToGL:touchLocation];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    CGRect selfRect = CGRectMake(self.position.x, self.position.y, self.contentSize.width, self.contentSize.height);
    return CGRectContainsPoint(selfRect, [self locationFromTouch:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if([self containsTouchLocation:touch]){
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    [_scale9Spr release];
    [_activityIndicatorView release];
    [_tipTxt release];
    [super dealloc];
}

@end
