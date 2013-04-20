//
//  BetBox.h
//  NiuNiu
//  下注数字盒子
//  Created by childhood on 13-4-20.
//
//

#import "cocos2d.h"

@interface BetBox : CCSprite <CCTargetedTouchDelegate>
{
    CCSprite *_bg;
    CCLabelTTF *_ratioLabel;
    int _ratio;
    BOOL _state;
}
+ (id)betBoxWithRatio:(int)ratio status:(BOOL)state;
- (id)initWithRatio:(int)ratio status:(BOOL)state;
@end
