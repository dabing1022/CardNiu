//
//  FamilyPropertyScene.h
//  NiuNiu 家产
//
//  Created by childhood on 13-4-7.
//
//

#import "CCLayer.h"

#import "cocos2d.h"

@interface FamilyPropertyScene : CCLayer <UIGestureRecognizerDelegate>
{
    //加入手势滑动切换场景
    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
}


@property(nonatomic, retain) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
+(CCScene *) scene;
@end
