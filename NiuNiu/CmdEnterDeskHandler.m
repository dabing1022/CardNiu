//
//  CmdEnterDeskHandler.m
//  NiuNiu
//
//  Created by childhood on 13-4-17.
//
//

#import "CmdEnterDeskHandler.h"
#import "GCDAsyncSocketHelper.h"
@implementation CmdEnterDeskHandler

+ (void)processEnterDeskData:(NSData *)data
{
    NSDictionary *dic = [[GCDAsyncSocketHelper sharedHelper]analysisDataToDictionary:data];

}
@end
