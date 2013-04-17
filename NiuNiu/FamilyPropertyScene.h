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
}


@property(nonatomic, retain) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
+(CCScene *) scene;
@end
