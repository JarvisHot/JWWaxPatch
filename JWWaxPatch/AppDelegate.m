//
//  AppDelegate.m
//  JWWaxPatch
//
//  Created by jiang on 2019/10/23.
//  Copyright © 2019 jarvis. All rights reserved.
//

#import "AppDelegate.h"
#import "lauxlib.h"
#import "wax.h"
#import "ZipArchive.h"
#import "RSATools.h"
#import "NSDictionary+json.h"

#define PATCH_URL @"https://github.com/JarvisHot/JWWaxPatch/blob/master/patch.json.zip?raw=true"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (id)init {
    if(self = [super init]) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
        [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
        
        NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", dir, dir];
        setenv(LUA_PATH, [pp UTF8String], 1);
    }
    return self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window makeKeyAndVisible];
    [self creatPatchJson];
//    [self loadPatch];
    
    // Override point for customization after application launch.
    return YES;
}
- (void)creatPatchJson {
    NSString * RSAPublicKey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqxHPSIzY3FOf7LqvdTaP9KCd1\nwDoxc6L5NPO/L6g+SYr8TGwAOYCLHWW7bBZNeafRo6VoA1JR3w0xMhdFxqzdW4Gq\nQx66rneICftkc7jqzKN/1nDNX2kV2pf6RiXn0yaSbJOqw/X5xRdOtGOPLTD9/WmF\nFClR+GN4aHeAU79XHwIDAQAB\n-----END PUBLIC KEY-----";
    
    NSData *zipData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patch" ofType:@"zip"]];
    NSString *patchStr = [zipData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSLog(@"patchStr---%@",patchStr);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建一个文件并且写入数据
    NSString *home = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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
    
    NSLog(@"主目录 = %@", home);

}
- (void)loadPatch {
    
    NSString *RSAPrivateKey = @"-----BEGIN PRIVATE KEY-----\nMIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKrEc9IjNjcU5/su\nq91No/0oJ3XAOjFzovk0878vqD5JivxMbAA5gIsdZbtsFk15p9GjpWgDUlHfDTEy\nF0XGrN1bgapDHrqud4gJ+2RzuOrMo3/WcM1faRXal/pGJefTJpJsk6rD9fnFF060\nY48tMP39aYUUKVH4Y3hod4BTv1cfAgMBAAECgYB+7ADBoNY83lcFhEzM8VX/ZQbf\nJ/6Ynr/0xXydDwjXMsYQe6SSDisSOslQIif5cYBf+meIBV/75fLiK77MZ7w2m2YY\ndw1o3w80vkjRxnQmI7OLBsXj7S67q5Z3cgg+JL2Zl7DKiJi0G7iikKbUIDnY9CjR\nJ97Q/pE3MLuDLyPGoQJBANOqci6LVfcAwcQNTtWBBV8iZ11/wgBhQlXu2PlYEce7\n1phFkRvGQTthgEyU9587le7eFkre0XPPTt0WHtKMikcCQQDOiQbsjMAxbMTV95YU\nP7ah+lE7LvuxgiamRlR584SOg4nSIJM42xzSrMlCPkJALQvnumEbjT5XufY39bx5\nwGBpAkAvRSVy15M/MmATlJVCgSnd8ST8cIe25gGWh1zVcqGl5YErSH37oe73f/LT\nJ4GVgg0d52M7HT/RiT6niUUg6FoJAkAz5DW7JTn8sQlbgRNSDxgB5nSWXB2c4ch4\nKl97LHX3oJD2HH0g4dyCCiue2ymmGitNk4RmebxaKjz0nmc2Z+FRAkAsg33dfDpH\n0yEMl7WxDoNkLcWf99Mq76bZZGDapvly0vGy8R1ThWRhP0dWJcLm3JIFHHE7W1Zr\nIlcp1unqlF/l\n-----END PRIVATE KEY-----";
    NSURL *patchUrl = [NSURL URLWithString:PATCH_URL];
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:patchUrl] returningResponse:NULL error:NULL];
    if(data) {
        NSLog(@"load data----%@",data);
            NSString *result =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            NSLog(@"result----%@",str);
        //先解压data
        NSData *patchJsonData =[[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];

//
            NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

            NSString *patchjsonZip = [doc stringByAppendingPathComponent:@"patch.json.zip"];
            [patchJsonData writeToFile:patchjsonZip atomically:YES];
        ZipArchive *zip = [[ZipArchive alloc]init];
        [zip UnzipOpenFile:patchjsonZip];
        [zip UnzipFileTo:doc overWrite:YES];
        NSData *jsonData = [NSData dataWithContentsOfFile:[doc stringByAppendingPathComponent:@"patch.json"]];
        NSDictionary *patchJson = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"patchjson---%@",patchJson);
        if ([[patchJson jsonString:@"version"] isEqualToString:[self AppVersion]]) {
            NSString *patchstr = [RSATools decryptString:[patchJson jsonString:@"patch"] publicKey:RSAPrivateKey];
            NSLog(@"patch str--%@",[patchJson jsonString:@"patch"]);
            
        }else {
            NSLog(@"版本不符合");
        }
//
//            NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
//            [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
//            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
//
//            ZipArchive *zip = [[ZipArchive alloc] init];
//            [zip UnzipOpenFile:patchZip];
//            [zip UnzipFileTo:dir overWrite:YES];
//
//            NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", dir, dir];
//            setenv(LUA_PATH, [pp UTF8String], 1);
//            wax_start("init.lua", nil);
//
        }
}
- (NSString *)AppVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return [infoDic objectForKey:@"CFBundleShortVersionString"];
    
}
#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
