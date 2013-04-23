//
//  UserCard.h
//  NiuNiu
//
//  Created by childhood on 13-4-15.
//
//

#import "cocos2d.h"

//定义牌结构
//type为花色，value为牌面大小
typedef struct
{
    int type;
    int value;
}CardData;

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
}CardType;

@interface UserCard : CCSprite<CCTargetedTouchDelegate>
{
    BOOL _isFront;
    BOOL _isPopup;
}

@property(nonatomic, assign)BOOL isFront;
@property(nonatomic, assign)BOOL isPopup;

- (id)initWithCardData:(CardData)cardData;
+ (id)cardWithCardData:(CardData)cardData;
- (id)initWithBack;
+ (id)cardWithBack;
- (void)popUpWithHeight:(int)height;
- (void)pullDownWithHeight:(int)height;
@end
