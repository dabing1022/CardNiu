//
//  CardPlayingScene.h
//  NiuNiu 牌局
//
//  Created by childhood on 13-4-7.
//
//

#import "cocos2d.h"
#import "CurtainTransitionDelegate.h"

enum{
    kTagCardPlayingScene,
    kTagAvatarInfoBox,
    kTagCurtain
};

#define POS_ID0 CGPointMake(55, 370)
#define POS_ID1 CGPointMake(55, 220)
#define POS_ID2 CGPointMake(55, 86)
#define POS_ID3 CGPointMake(264, 170)
#define POS_ID4 CGPointMake(55, 310)
#define POS_ID5 CGPointMake(170, 432)

@class ProfilePanel;
@interface CardPlayingScene : CCLayer <UIGestureRecognizerDelegate,CurtainTransitionDelegate,UIAlertViewDelegate>
{
    //加入手势滑动切换场景
    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
    UIActivityIndicatorView *_activityIndicatorView;

}

@property(nonatomic, retain) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
+(CCScene *) scene;


@end
