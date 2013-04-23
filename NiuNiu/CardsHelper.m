//
//  CardsHelper.m
//  NiuNiu
//
//  Created by childhood on 13-4-23.
//
//

#import "CardsHelper.h"
#import "UserCard.h"

@implementation CardsHelper
@synthesize cardResultForResource=_cardResultForResource;

static CardsHelper *_instance = nil;

+ (CardsHelper *)sharedHelper
{
    if(!_instance)
    {
        _instance = [[self alloc]init];
    }
    return _instance;
}

- (id)init
{
    if((self = [super init]))
    {
        self.cardResultForResource = [NSMutableArray arrayWithCapacity:13];
        for(int i = 0;i < 13;i++){
            [self.cardResultForResource addObject:[NSString stringWithFormat:@"resultNiu%d.png",i]];
        }
    }
    return self;
}

//分析牌数据


- (CardData)getCardDataFromCardDic:(NSDictionary *)cardDic
{
    CardData cardData;
    cardData.color = [[cardDic objectForKey:@"color"]intValue];
    cardData.value = [[cardDic objectForKey:@"value"]intValue];
    return cardData;
}

//得到牌值的真实值
//1-->10为1-->10,而11、12、13为10
- (int)getNiuRealValue:(int)value
{
    if(value >= CARD_10 && value <= CARD_K){
        return 10;
    }else if(value >= CARD_A && value <= CARD_10){
        return value;
    }
    return -1;
}

//得到5张牌的真实值总和
- (int)getCardsSum:(NSArray *)cardsDataArr
{
    int sum = 0;
    for(int i = 0; i < [cardsDataArr count]; i++){
        NSDictionary *singleCardData = [cardsDataArr objectAtIndex:i];
        CardData cardData = [self getCardDataFromCardDic:singleCardData];
        sum += [self getNiuRealValue:cardData.value];
    }
    return sum;
}

//判断是否是4炸，返回一个字典
//字典内：bomb = YES/NO, cardIndex = [0, 2, 3, 4]
- (NSDictionary *)judgeBomb:(NSArray *)cardsDataArr
{
    NSMutableArray *valueArr = [self getValueArrayBy:cardsDataArr];
        
    int i, j, m, n;
    NSDictionary *dic;
    for(i = 0; i <= 1; i++){
        for(j = i + 1; j <= 2; j++){
            for(m = j + 1; m <= 3; m++){
                for(n = m + 1; n <= 4; n++){
                    int k = [[valueArr objectAtIndex:i]intValue];
                    if([[valueArr objectAtIndex:i]intValue] == k
                       && [[valueArr objectAtIndex:j]intValue] == k
                       && [[valueArr objectAtIndex:m]intValue] == k
                       && [[valueArr objectAtIndex:n]intValue] == k)
                    {
                        NSNumber *bomb = [NSNumber numberWithBool:YES];
                        NSArray *index = [NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                                                   [NSNumber numberWithInt:j],
                                                                   [NSNumber numberWithInt:m],
                                                                   [NSNumber numberWithInt:n], nil];
                        dic = [[NSDictionary alloc]initWithObjectsAndKeys:bomb,@"bomb",index,@"cardsIndex", nil];
                        return dic;
                    }
                }
            }
        }
    }
    return nil;
}

- (NSMutableArray *)getValueArrayBy:(NSArray *)cardsDataArr
{
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:[cardsDataArr count]];
    for(int i = 0; i < [cardsDataArr count]; i++){
        NSDictionary *singleCardData = [cardsDataArr objectAtIndex:i];
        CardData cardData = [self getCardDataFromCardDic:singleCardData];
        [valueArr addObject:[NSNumber numberWithInt:cardData.value]];
    }
    return valueArr;
}

- (NSMutableArray *)getRealValueArrayBy:(NSArray *)cardsDataArr
{
    NSMutableArray *realValueArr = [NSMutableArray arrayWithCapacity:[cardsDataArr count]];
    for(int i = 0; i < [cardsDataArr count]; i++){
        NSDictionary *singleCardData = [cardsDataArr objectAtIndex:i];
        CardData cardData = [self getCardDataFromCardDic:singleCardData];
        [realValueArr addObject:[NSNumber numberWithInt:[self getNiuRealValue:cardData.value]]];
    }
    return realValueArr;
}

//判断5花牛
- (NSDictionary *)judgeWuHua:(NSArray *)cardsDataArr
{
    NSMutableArray *valueArr = [self getValueArrayBy:cardsDataArr];
    for(int i = 0; i < [valueArr count]; i++){
        int value = [[valueArr objectAtIndex:i]intValue];
        if(![self isHuaSe:value]){
            return nil;
        }
    }
    NSNumber *wuhua = [NSNumber numberWithBool:YES];
    NSArray *index = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                                               [NSNumber numberWithInt:1],
                                               [NSNumber numberWithInt:2],
                                               [NSNumber numberWithInt:3],
                                               [NSNumber numberWithInt:4], nil];

    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:wuhua,@"wuhua",index,@"cardsIndex", nil];
    return dic;
}

//判断一般牌型（无牛、牛一、牛二、、、牛牛）
- (NSDictionary *)judgeNomalNiu:(NSArray *)cardsDataArr
{
    NSMutableArray *realValueArr = [self getValueArrayBy:cardsDataArr];
    int sum = [self getCardsSum:cardsDataArr];
    int i, j, k, tempSum;
    NSNumber *cardType;
    NSArray *index;
    NSDictionary *dic;
    for(i = 0; i <= 2; i++){
        for(j = i + 1; j <= 3; j++){
            for(k = j + 1; k <= 4; k++){
                tempSum = [[realValueArr objectAtIndex:i]intValue] + [[realValueArr objectAtIndex:j]intValue] + [[realValueArr objectAtIndex:k]intValue];
                if(tempSum % 10 == 0){
                    cardType = [NSNumber numberWithInt:((sum - tempSum) % 10)];
                    index = [NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                                      [NSNumber numberWithInt:j],
                                                      [NSNumber numberWithInt:k], nil];

                    dic = [[NSDictionary alloc]initWithObjectsAndKeys:cardType,@"cardType",index,@"cardsIndex", nil];
                    return dic;
                }
            }
        }
    }
    return nil;
}

- (BOOL)isHuaSe:(int)value
{
    return (value >= 11 && value <= 13);
}

@end