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

//分析5张牌数据
- (NSDictionary *)analysisWholeCards:(NSMutableArray *)cardsDataArr
{
    if([self judgeBomb:cardsDataArr]){
        return [self judgeBomb:cardsDataArr];
    }
    if([self judgeWuHua:cardsDataArr]){
        return [self judgeWuHua:cardsDataArr];
    }
    if([self judgeNomalNiu:cardsDataArr]){
        return [self judgeNomalNiu:cardsDataArr];
    }
    
    NSNumber *cardType = [NSNumber numberWithInt:NIU_0];
    NSDictionary *index = nil;
    NSDictionary *resultWuNiuDic = [[NSDictionary alloc]initWithObjectsAndKeys:cardType, @"cardType", index, @"cardsIndex", nil];
    return resultWuNiuDic;
}

- (NSDictionary *)analysisSelectedCards:(NSMutableArray *)selectedCardsDataArr wholeCardsDataArr:(NSMutableArray *)wholeCardsDataArr
{
    NSUInteger selectedLength = [selectedCardsDataArr count];
    int selectedSum = [self getCardsSum:selectedCardsDataArr];
    int wholeSum = [self getCardsSum:wholeCardsDataArr];
    int leftValue = (wholeSum - selectedSum) % 10;
    CCLOG(@"selectedSum: %d",selectedSum);
    CCLOG(@"wholeSum: %d", wholeSum);
    CCLOG(@"leftValue: %d", leftValue);
    NSNumber *cardType;
    NSArray *index;
    NSDictionary *resultDic;
    if(selectedLength == 3 && selectedSum % 10 == 0){
        if(leftValue == 0)
            cardType = [NSNumber numberWithInt:NIU_NIU];
        else
            cardType = [NSNumber numberWithInt:leftValue];
    }else{
        cardType = [NSNumber numberWithInt:NIU_0];
    }
    index = [self getOneArrIndexInAnotherArr:selectedCardsDataArr wholeArr:wholeCardsDataArr];
    resultDic = [[NSDictionary alloc]initWithObjectsAndKeys:cardType, @"cardType", index, @"cardsIndex", nil];
    return resultDic;
}

- (NSArray *)getOneArrIndexInAnotherArr:(NSArray *)subArr wholeArr:(NSArray *)wholeArr
{
    int subArrLen = [subArr count];
    if(subArrLen == 0)return nil;
    int wholeArrLen = [wholeArr count];
    NSMutableArray *index = [NSMutableArray arrayWithCapacity:subArrLen];
    for(int i = 0; i < subArrLen; i++){
        for(int j = 0; j < wholeArrLen; j++){
            if([subArr objectAtIndex:i] == [wholeArr objectAtIndex:j]){
                [index addObject:[NSNumber numberWithInt:j]];
            }
        }
    }
    NSArray *indexSorted = [index sortedArrayUsingSelector:@selector(compare:)];
    return indexSorted;
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

//得到若干牌的真实值总和
- (int)getCardsSum:(NSMutableArray *)cardsDataArr
{
    int sum = 0;
    for(int i = 0; i < [cardsDataArr count]; i++){
        CardData *cardData = [cardsDataArr objectAtIndex:i];
        sum += [self getNiuRealValue:cardData.value];
    }
    return sum;
}

//判断是否是4炸，返回一个字典
//字典内：bomb = YES/NO, cardIndex = [0, 2, 3, 4]
- (NSDictionary *)judgeBomb:(NSMutableArray *)cardsDataArr
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
                        NSNumber *cardType = [NSNumber numberWithInt:ZHA_DAN];
                        NSArray *index = [NSArray arrayWithObjects:[NSNumber numberWithInt:i],
                                                                   [NSNumber numberWithInt:j],
                                                                   [NSNumber numberWithInt:m],
                                                                   [NSNumber numberWithInt:n], nil];
                        dic = [[NSDictionary alloc]initWithObjectsAndKeys:cardType,@"cardType",index,@"cardsIndex", nil];
                        CCLOG(@"炸弹！");
                        return dic;
                    }
                }
            }
        }
    }
    return nil;
}

- (NSMutableArray *)getValueArrayBy:(NSMutableArray *)cardsDataArr
{
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:[cardsDataArr count]];
    for(int i = 0; i < [cardsDataArr count]; i++){
        CardData *cardData = [cardsDataArr objectAtIndex:i];
        [valueArr addObject:[NSNumber numberWithInt:cardData.value]];
    }
    return valueArr;
}

- (NSMutableArray *)getRealValueArrayBy:(NSMutableArray *)cardsDataArr
{
    NSMutableArray *realValueArr = [NSMutableArray arrayWithCapacity:[cardsDataArr count]];
    for(int i = 0; i < [cardsDataArr count]; i++){
        CardData *cardData = [cardsDataArr objectAtIndex:i];
        [realValueArr addObject:[NSNumber numberWithInt:[self getNiuRealValue:cardData.value]]];
    }
    return realValueArr;
}

//判断5花牛
- (NSDictionary *)judgeWuHua:(NSMutableArray *)cardsDataArr
{
    for(int i = 0; i < [cardsDataArr count]; i++){
        CardData *cardData =  [cardsDataArr objectAtIndex:i];
        if(![self isHuaSe:cardData.value]){
            return nil;
        }
    }
    NSNumber *cardType = [NSNumber numberWithInt:WU_HUA];
    NSArray *index = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                                               [NSNumber numberWithInt:1],
                                               [NSNumber numberWithInt:2],
                                               [NSNumber numberWithInt:3],
                                               [NSNumber numberWithInt:4], nil];

    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:cardType,@"cardType",index,@"cardsIndex", nil];
    CCLOG(@"五花牛!");
    return dic;
}

//判断一般牌型（无牛、牛一、牛二、、、牛牛）
- (NSDictionary *)judgeNomalNiu:(NSMutableArray *)cardsDataArr
{
    NSMutableArray *realValueArr = [self getRealValueArrayBy:cardsDataArr];
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
                    CCLOG(@"牛%@!",cardType);
                    return dic;
                }
            }
        }
    }
    return nil;
}

//cardsDataArray [ 3CardData, 4CardData, 8CardData, 9CardData, 10CardData ]
//cardsIndex    [ 1, 3, 4 ]  --> 1，3，4作为cardsDataArray的索引去取其中的值
//返回 [ 4CardData, 9CardData, 10CardData, 3CardData, 8CardData ]
- (NSMutableArray *)sortCardsDataByCardsIndex:(NSArray *)cardsIndex cardsDataArray:(NSMutableArray *)cardsDataArray
{
    for(int i = 0; i < [cardsIndex count]; i++){
        int index = [[cardsIndex objectAtIndex:i]intValue];
        id data = [cardsDataArray objectAtIndex:index];
        [cardsDataArray removeObjectAtIndex:index];
        [cardsDataArray insertObject:data atIndex:i];
    }
    return cardsDataArray;
}

//找到数组中和给定值相等的值所在的索引
- (int)findIndexValueEqualsTo:(int)value inArray:(NSArray *)array
{
    for(int i = 0; i < [array count]; i++)
    {
        if([[array objectAtIndex:i]intValue] == value)
            return i;
    }
    return -1;
}

- (BOOL)isHuaSe:(int)value
{
    return (value >= 11 && value <= 13);
}

@end