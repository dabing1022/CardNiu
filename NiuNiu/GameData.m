//
//  GameData.m
//  NiuNiu
//
//  Created by childhood on 13-4-15.
//
//

#import "GameData.h"
#import "User.h"

@implementation GameData
@synthesize player=_player;
static GameData *_instance = nil;


+ (GameData *)sharedGameData
{
    if(!_instance)
    {
        _instance = [[self alloc]init];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.player = nil;
    }
    return self;
}

- (void)dealloc
{
    _instance = nil;
    [super dealloc];
}
@end
