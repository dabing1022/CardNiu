//
//  CardPlayingHandler.h
//  NiuNiu
//
//  Created by childhood on 13-4-18.
//
//

#import <Foundation/Foundation.h>
@class User;

@interface CardPlayingHandler : NSObject

+ (void)processEnterDeskData:(NSData *)data;
+ (User *)processOtherPlayerIn:(NSData *)data;
+ (User *)processViewProfile:(NSData *)data;
+ (NSString *)processGrabZ:(NSData *)data;
+ (NSString *)processGrabResult:(NSData *)data;
+ (NSArray *)processStartBet:(NSData *)data;
+ (NSDictionary *)processOtherPlayerBetResult:(NSData *)data;
+ (NSMutableArray *)processCardData:(NSData *)data;
+ (NSMutableArray *)cardDataDicArr2cardsDataArr:(NSArray *)cardDataDicArr;
+ (NSDictionary *)processStartShowCards:(NSData *)data;
@end
