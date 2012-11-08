//
//  MTCoderUtile.m
//  YunSDK
//
//  Created by zrz on 12-10-31.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTCoderUtile.h"
#import <CommonCrypto/CommonHMAC.h>

#pragma mark - base 64

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

NSString *encodeBase64WithData(NSData *objData) {
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    int intLength = [objData length];
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while(intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    // Return the results as an NSString object
    return[NSString stringWithCString:strResult
                             encoding:NSASCIIStringEncoding];
}

@implementation MTCoderUtile

+ (NSString *)oauthSignature:(NSString *)method
                         url:(NSString *)urlString
                      params:(NSDictionary *)params
                      secret:(NSString *)secret
{
    NSString *urlHeader = [NSMutableString stringWithFormat:@"%@&%@&",
                           method, [self encodeWithUTF8:
                                    [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSMutableString *paramsString = [NSMutableString string];
    NSArray *allKey = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (int n = 0, t = allKey.count; n < t; n++) {
        if (n) {
            [paramsString appendString:@"&"];
        }
        NSString *key = [allKey objectAtIndex:n];
        [paramsString appendFormat:@"%@=%@", key,
         [self encodeWithUTF8:[params objectForKey:key]]];
    }
    
    return [self encodeWithHMAC_SHA1:
            [urlHeader stringByAppendingString:[self encodeWithUTF8:paramsString]]
                              secret:secret];
}


+ (NSString *)encodeWithUTF8:(NSString *)inString
{
    return (__bridge_transfer NSString *)
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, //Allocator
                                            (__bridge CFStringRef)inString, //Original String
                                            NULL, //Characters to leave unescaped
                                            CFSTR("!*'();:@&=+$,/?%#[]"), //Legal Characters to be escaped
                                            kCFStringEncodingUTF8);
}

+ (NSString *)encodeWithHMAC_SHA1:(NSString *)inString
                           secret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [inString dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], cHMAC);
    
    return encodeBase64WithData([NSData dataWithBytes:cHMAC length:20]);
}

+ (NSDictionary *)decodeURLString:(NSString *)urlString
{
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.length == 0 || range.location == NSNotFound) {
        //没有问号
        return nil;
    }
    
    NSMutableDictionary *outDic = [NSMutableDictionary dictionary];
    
    NSString *subString = [urlString substringFromIndex:range.location + range.length];
    NSArray *paramsArray = [subString componentsSeparatedByString:@"&"];
    for (NSString *string in paramsArray) {
        NSArray *keyValueArr = [string componentsSeparatedByString:@"="];
        if (keyValueArr.count == 2) {
            [outDic setObject:[keyValueArr objectAtIndex:1]
                       forKey:[keyValueArr objectAtIndex:0]];
        }
    }
    return [outDic mutableCopy];
}

+ (NSString *)encodeURLWithBaseURLString:(NSString *)urlString
                               params:(NSDictionary *)params
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@?", urlString];
    __block BOOL first = YES;
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!first) {
            [string appendString:@"&"];
        }else first = NO;
        
        [string appendFormat:@"%@=%@", key, obj];
    }];
    
    return string;
}

@end
