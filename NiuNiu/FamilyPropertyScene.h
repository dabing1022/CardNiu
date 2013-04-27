//
//  FamilyPropertyScene.h
//  NiuNiu 家产
//
//  Created by childhood on 13-4-7.
//
//

#import "cocos2d.h"
#import "CurtainTransitionDelegate.h"

#define kTagFamilyPropertyScene 0
@interface FamilyPropertyScene : CCLayer <UIGestureRecognizerDelegate,CurtainTransitionDelegate,UIAlertViewDelegate>
{
    //加入手势滑动切换场景
    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
    
    //家产按钮ITEM
    CCMenuItemImage *_familyPropertyMenuItemNomal;
    CCMenuItemImage *_familyPropertyMenuItemSelected;
    CCMenuItemToggle *_familyPropertyItemToggle;
    //卡牌按鈕ITEM
    CCMenuItemImage *_cardMenuItemNomal;
    CCMenuItemImage *_cardMenuItemSelected;
    CCMenuItemToggle *_cardItemToggle;
    //狀態按鈕ITEM
    CCMenuItemImage *_stateMenuItemNomal;
    CCMenuItemImage *_stateMenuItemSelected;
    CCMenuItemToggle *_stateItemToggle;
    CCMenu *_navigateMenu;
    
    CCLayer *_familyPropertyLayer;
    CCLayer *_cardLayer;
    CCLayer *_stateLayer;
    CCLayerMultiplex *_multiplexLayer;
    
    CCSprite *_flipSpriteTest;
    CCSprite *_flipSpriteTest2;
}


@property(nonatomic, retain) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
+(CCScene *) scene;
@end
