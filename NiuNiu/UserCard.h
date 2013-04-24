//
//  UserCard.h
//  NiuNiu
//
//  Created by childhood on 13-4-15.
//
//

#import "cocos2d.h"

//卡牌被点击选中后上下移动距离
#define CARD_POP_DOWN_HEIGHT 20


//定义牌数据结构
//type为花色，value为牌面大小
@interface CardData : NSObject
{
    int color;
    int value;
}
@property(nonatomic, assign)int color;
@property(nonatomic, assign)int value;
@end

typedef enum
{
    CARD_A = 1,
    CARD_2,
    CARD_3,
    CARD_4,
    CARD_5,
    CARD_6,
    CARD_7,
    CARD_8,
    CARD_9,
    CARD_10,
    CARD_J,
    CARD_Q,
    CARD_K
}CardValue;

typedef enum
{
    HEI = 4,
    HONG = 3,
    MEI = 2,
    FANG = 1
}CardColor;

typedef enum
{
    NIU_0 = 0,
    NIU_1 = 1,
    NIU_2 = 2,
    NIU_3 = 3,
    NIU_4 = 4,
    NIU_5 = 5,
    NIU_6 = 6,
    NIU_7 = 7,
    NIU_8 = 8,
    NIU_9 = 9,
    NIU_NIU = 10,
    ZHA_DAN = 11,
    WU_HUA = 12
}NiuType;

@interface UserCard : CCSprite<CCTargetedTouchDelegate>
{
    BOOL _isFront;
    BOOL _isPopup;
    CardData *_cardData;
}

@property(nonatomic, assign)BOOL isFront;
@property(nonatomic, assign)BOOL isPopup;
@property(nonatomic, retain)CardData *cardData;

- (id)initWithCardData:(CardData *)cardData;
+ (id)cardWithCardData:(CardData *)cardData;
- (id)initWithBack;
+ (id)cardWithBack;
- (void)setFrontFace:(CardData *)cardData;
- (void)setBackFace;
- (void)popUp;
- (void)pullDown;
- (void)handlePopAndDown;
@end
