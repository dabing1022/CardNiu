//
//  GameData.m
//  NiuNiu
//
//  Created by childhood on 13-4-15.
//
//

#import "GameData.h"

@implementation GameData
@synthesize player;
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
    if((self = [super init]))
    {
        
    }
    return self;
}

- (void)dealloc
{
    _instance = nil;
    [super dealloc];
}
@end
