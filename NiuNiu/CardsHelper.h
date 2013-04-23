//
//  CardsHelper.h
//  NiuNiu
//
//  Created by childhood on 13-4-23.
//
//

#import <Foundation/Foundation.h>
#import "UserCard.h"

@interface CardsHelper : NSObject
{
    NSMutableArray *_cardResultForResource;
}

@property(nonatomic, retain) NSMutableArray *cardResultForResource;
+ (CardsHelper *)sharedHelper;
- (CardData)getCardDataFromCardDic:(NSDictionary *)cardDic;
- (int)getNiuRealValue:(int)value;
- (int)getCardsSum:(NSArray *)cardsDataArr;
//判断4炸
- (NSDictionary *)judgeBomb:(NSArray *)cardsDataArr;
//判断5花牛
- (NSDictionary *)judgeWuHua:(NSArray *)cardsDataArr;
//判断一般牛
- (NSDictionary *)judgeNomalNiu:(NSArray *)cardsDataArr;
@end
