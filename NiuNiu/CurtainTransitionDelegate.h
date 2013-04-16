//
//  CurtainTransitionDelegate.h
//  NiuNiu
//  幕布上下关闭拉开效果
//  Created by childhood on 13-4-16.
//
//

#import <Foundation/Foundation.h>

@protocol CurtainTransitionDelegate <NSObject>
- (void)closeCurtainWithSel:(SEL)sel;
- (void)openCurtain;
@end
