//
//  ReadingCardsLayer.h
//  NiuNiu
//  读牌层
//  Created by childhood on 13-4-22.
//
//

#import "CCLayer.h"


#define FIRST_CARD_BELOW_POS CGPointMake(100, 50)
#define FIRST_CARD_UP_POS    CGPointMake(100, 400)
#define CARDS_SPACING 50

@class UserCard;
@interface ReadingCardsLayer : CCLayerColor
{
    NSArray *_cardsDataArray;
    NSMutableArray *_userCardsArray;
}


+ (id)layerWithCardsArray:(NSArray *)cardsArray;
@end
