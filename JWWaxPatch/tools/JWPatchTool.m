//
//  JWPatchTool.m
//  JWWaxPatch
//
//  Created by jiang on 2019/10/29.
//  Copyright © 2019 jarvis. All rights reserved.
//

#import "JWPatchTool.h"
#import "lauxlib.h"
#import "wax.h"
#import "ZipArchive.h"
#import "RSATools.h"
#import "NSDictionary+json.h"
#import <AFNetworking/AFNetworking.h>

#define PATCH_URL @"https://github.com/JarvisHot/JWWaxPatch/blob/master/patch.json.zip?raw=true"

 NSString *const RSAPublicKey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqxHPSIzY3FOf7LqvdTaP9KCd1\nwDoxc6L5NPO/L6g+SYr8TGwAOYCLHWW7bBZNeafRo6VoA1JR3w0xMhdFxqzdW4Gq\nQx66rneICftkc7jqzKN/1nDNX2kV2pf6RiXn0yaSbJOqw/X5xRdOtGOPLTD9/WmF\nFClR+GN4aHeAU79XHwIDAQAB\n-----END PUBLIC KEY-----";

NSString *const RSAPrivateKey = @"-----BEGIN PRIVATE KEY-----\nMIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKrEc9IjNjcU5/su\nq91No/0oJ3XAOjFzovk0878vqD5JivxMbAA5gIsdZbtsFk15p9GjpWgDUlHfDTEy\nF0XGrN1bgapDHrqud4gJ+2RzuOrMo3/WcM1faRXal/pGJefTJpJsk6rD9fnFF060\nY48tMP39aYUUKVH4Y3hod4BTv1cfAgMBAAECgYB+7ADBoNY83lcFhEzM8VX/ZQbf\nJ/6Ynr/0xXydDwjXMsYQe6SSDisSOslQIif5cYBf+meIBV/75fLiK77MZ7w2m2YY\ndw1o3w80vkjRxnQmI7OLBsXj7S67q5Z3cgg+JL2Zl7DKiJi0G7iikKbUIDnY9CjR\nJ97Q/pE3MLuDLyPGoQJBANOqci6LVfcAwcQNTtWBBV8iZ11/wgBhQlXu2PlYEce7\n1phFkRvGQTthgEyU9587le7eFkre0XPPTt0WHtKMikcCQQDOiQbsjMAxbMTV95YU\nP7ah+lE7LvuxgiamRlR584SOg4nSIJM42xzSrMlCPkJALQvnumEbjT5XufY39bx5\nwGBpAkAvRSVy15M/MmATlJVCgSnd8ST8cIe25gGWh1zVcqGl5YErSH37oe73f/LT\nJ4GVgg0d52M7HT/RiT6niUUg6FoJAkAz5DW7JTn8sQlbgRNSDxgB5nSWXB2c4ch4\nKl97LHX3oJD2HH0g4dyCCiue2ymmGitNk4RmebxaKjz0nmc2Z+FRAkAsg33dfDpH\n0yEMl7WxDoNkLcWf99Mq76bZZGDapvly0vGy8R1ThWRhP0dWJcLm3JIFHHE7W1Zr\nIlcp1unqlF/l\n-----END PRIVATE KEY-----";

const 

@implementation JWPatchTool

static JWPatchTool *PatchTool = nil;
+ (void)extracted {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSString *pp = [[NSString alloc ] initWithFormat:@"%@/patch/?.lua;%@/?/init.lua;", dir, dir];
    setenv(LUA_PATH, [pp UTF8String], 1);
}

+ (JWPatchTool *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (PatchTool == nil) {
            PatchTool = [[self alloc] init];
            
        }
    });
//    [self extracted];
    return PatchTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (PatchTool == nil) {
            PatchTool = [super allocWithZone:zone];
        }
    });
    return PatchTool;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return PatchTool;
}

- (void)loadLocalPatchWithFileName:(char *)fileName {
    wax_start(fileName, nil);
}

+ (NSString *)creatPatchJson {
    
    NSData *zipData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patch" ofType:@"zip"]];
    NSString *patchStr = [zipData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//    NSLog(@"patchStr---%@",patchStr);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建一个文件并且写入数据
    NSString *home = NSTemporaryDirectory();
    NSString *path = [home stringByAppendingPathComponent:@"patch.json"];
    NSFileHandle *filehandler;
    if ([fileManager fileExistsAtPath:path]) {
        filehandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
    }else{
        [fileManager createFileAtPath:path contents:nil attributes:nil];
        filehandler = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    NSDictionary *dic = @{@"version":[self AppVersion],@"patch":[RSATools encryptString:patchStr publicKey:RSAPublicKey]};
    [filehandler writeData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingFragmentsAllowed error:nil]];
    
//    NSLog(@"主目录 = %@", home);
    return path;

}
+ (void)requestPatchWithUrl:(NSString *)urlStr {
    /* 创建网络下载对象 */
//    [[self class]extracted];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    /* 下载地址 */
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    /* 下载路径 */
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *patchjsonZip = [doc stringByAppendingPathComponent:@"patch.json.zip"];
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //如果需要进行UI操作，需要获取主线程进行操作
        });
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:patchjsonZip];
                
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
         NSLog(@"下载完成");
        ZipArchive *zip = [[ZipArchive alloc]init];
        [zip UnzipOpenFile:patchjsonZip];
        [zip UnzipFileTo:doc overWrite:YES];
        NSData *jsonData = [NSData dataWithContentsOfFile:[doc stringByAppendingPathComponent:@"patch.json"]];
        NSDictionary *patchJson = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"主目录 = %@", doc);
        NSLog(@"patchjson---%@",patchJson);
        
        if ([[patchJson jsonString:@"version"] isEqualToString:[self AppVersion]]) {
            NSString *patchstr = [RSATools decryptString:[patchJson jsonString:@"patch"] privateKey:RSAPrivateKey];
            NSLog(@"patch str--%@",patchstr);
            dispatch_async(dispatch_get_main_queue(), ^{
                //如果需要进行UI操作，需要获取主线程进行操作
                [self loadPatchWithPatchString:patchstr];
            });
            
        }else {
            NSLog(@"版本不符合");
        }
         
    }];
     [downloadTask resume];
}
//加载patch文件
+ (void)loadPatchWithPatchString:(NSString *)patchStr {
    
    NSData *myData = [[NSData alloc]initWithBase64EncodedString:patchStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
       
       NSString *patchZip = [doc stringByAppendingPathComponent:@"patch.zip"];
       [myData writeToFile:patchZip atomically:YES];
       
       NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
       [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
       [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
       
       ZipArchive *zip = [[ZipArchive alloc] init];
       [zip UnzipOpenFile:patchZip];
       [zip UnzipFileTo:dir overWrite:YES];
       
       NSString *pp = [[NSString alloc ] initWithFormat:@"%@/patch/?.lua;%@/?/init.lua;", dir, dir];
       setenv(LUA_PATH, [pp UTF8String], 1);
       wax_start("patch.lua", nil);
}

+ (NSString *)AppVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return [infoDic objectForKey:@"CFBundleShortVersionString"];
    
}

@end
