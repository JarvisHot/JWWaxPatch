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
    NSString *str = @"";
    NSData *myData = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *patchZip = [doc stringByAppendingPathComponent:@"patch.zip"];
    [myData writeToFile:patchZip atomically:YES];
    
    NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:patchZip];
    [zip UnzipFileTo:dir overWrite:YES];
    
    NSString *pp = [[NSString alloc ] initWithFormat:@"%@/?.lua;%@/?/init.lua;", dir, dir];
    setenv(LUA_PATH, [pp UTF8String], 1);
    wax_start("patch.lua", nil);
    // Override point for customization after application launch.
    return YES;
}
- (void)creatPatchJson {
    NSString * RSAPublicKey = @"-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBxYT5ySLSSVdVr964zKak1gGBe7nMrFAM5/FR4k2IALiYidqYMuyXOndEE7hYjAVS642W5FFOcA0KpNu3dwn9gHMbdITuCiR31gpI21kolCPDBVUnE2MWU3tqiP2RT8o8pWTwMkZ5dZ6zZFzUDBH2GbyrFp9YD09MXPOrmVEG8QIDAQAB-----END PUBLIC KEY-----";
    NSString *RSAPrivateKey = @"-----BEGIN RSA PRIVATE KEY-----MIICWwIBAAKBgQDBxYT5ySLSSVdVr964zKak1gGBe7nMrFAM5/FR4k2IALiYidqYMuyXOndEE7hYjAVS642W5FFOcA0KpNu3dwn9gHMbdITuCiR31gpI21kolCPDBVUnE2MWU3tqiP2RT8o8pWTwMkZ5dZ6zZFzUDBH2GbyrFp9YD09MXPOrmVEG8QIDAQABAoGAcYxRdB5NbXTU3L2GgjxKmuVdVIcwRaPj9OwmGZnHXR8vDRQbKH0O7z+vjBESQbErnX+zJOz+SDyZJ9ebeVMkYoZrlI0FS5U7W6BUD90GaJusUtOk6m3XTjVJ26mfVLj9PZ/xZhABrJIJ3eQDgf1B3Wns3KeMJXUkNaCHJqbJ6QECQQD26YLcXOSE7CU1Cxn02nFp2cBHMk6lBR1Gf3d/lc/zu25ln63ADFHiolIa+QYYAes05aqUnnjOkzTb2/1KBXu5AkEAyOdMwhzw5Izr6/N5+of0/CCxEkoAONB+cjn9aZax3aGZgAKnMx2RKkKxc9RW5N1/Jl1RRR/ZTFldF5QL95Ew+QJATkQ6zOtNLK1GJgg81BaiOLFjd64Eq95xJzWkhXbRkirplaEGDIhbNIHLkO0690U0b3IVnkKVfLXA3ahgI6SVUQJAR5kG5fbictE2EvTGd96UFHaiJF5zDcxgA91ezo6B/PZmehR3+eODpIf4Lcty3EWD1uxS1kuvaWI/pvOAAE6iIQJAPndJqwJ5OlFwC11z5GRcn+cqD+ldY1rhDF0kE8TJIaOGjPCBOQLGwzH30RRntmSUe9/T+Gco/kPkEDVdUwfnBg==-----END RSA PRIVATE KEY-----";
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
