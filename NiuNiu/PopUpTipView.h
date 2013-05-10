//
//  PopUpTipView.h
//  NiuNiu
//
//  Created by childhood on 13-5-8.
//
//

#import "cocos2d.h"
#import "CCScale9Sprite.h"

typedef enum
{
    kTipType_WAIT_FOR_ASSIGN_IN_DESK=0,
    kTipType_CONNECT_CARD_SERVER=1,
    kTipType_RECONNECT_CARD_SERVER=2
}TIP_TYPE;

@interface PopUpTipView : CCLayerColor<CCTargetedTouchDelegate>
{
    CCScale9Sprite *_scale9Spr;
    UIActivityIndicatorView *_activityIndicatorView;
    CCLabelTTF *_tipTxt;
    int _type;
}

+ (id)viewWithType:(int)type;
- (id)initWithType:(int)type;

@property(nonatomic, retain)CCScale9Sprite *scale9spr;
@property(nonatomic, assign)int type;
@property(nonatomic, retain)CCLabelTTF *tipTxt;
@end
