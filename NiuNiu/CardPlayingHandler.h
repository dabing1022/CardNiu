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
@end
