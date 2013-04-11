//
//  GCDAyncSocketHelper.h
//  NiuNiu
//
//  Created by childhood on 13-4-11.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCDAsyncSocket.h"

@protocol NiuNiuGCDAsyncSocketDelegate <NSObject>

- (void) connect;
- (NSData *) wrapPacketWithCmd:(NSUInteger)cmd contentDic:(NSDictionary *)contentDic;
- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
@end


@interface GCDAyncSocketHelper : NSObject <NiuNiuGCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_mySocket;
}
@property(nonatomic, retain) GCDAsyncSocket *socket;



@end
