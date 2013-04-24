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
- (int)getNiuRealValue:(int)value;
- (int)getCardsSum:(NSArray *)cardsDataArr;
//判断4炸
- (NSDictionary *)judgeBomb:(NSMutableArray *)cardsDataArr;
//判断5花牛
- (NSDictionary *)judgeWuHua:(NSMutableArray *)cardsDataArr;
//判断一般牛
- (NSDictionary *)judgeNomalNiu:(NSMutableArray *)cardsDataArr;
//分析牌型(包括4炸、5花牛、一般牛)
- (NSDictionary *)analysisWholeCards:(NSMutableArray *)cardsDataArr;
//分析玩家本人所选的张数所形成的牌型
- (NSDictionary *)analysisSelectedCards:(NSMutableArray *)selectedCardsDataArr wholeCardsDataArr:(NSMutableArray *)wholeCardsDataArr;
- (int)findIndexValueEqualsTo:(int)value inArray:(NSArray *)array;
- (NSMutableArray *)sortCardsDataByCardsIndex:(NSArray *)cardsIndex cardsDataArray:(NSMutableArray *)cardsDataArray;
@end
