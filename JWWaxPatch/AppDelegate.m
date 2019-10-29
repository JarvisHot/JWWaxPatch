//
//  AppDelegate.m
//  JWWaxPatch
//
//  Created by jiang on 2019/10/23.
//  Copyright © 2019 jarvis. All rights reserved.
//

#import "AppDelegate.h"
#import "JWPatchTool.h"
#define PATCH_URL @"https://github.com/JarvisHot/JWWaxPatch/blob/master/patch.json.zip?raw=true"
#import "lauxlib.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (id)init {
    if(self = [super init]) {
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        NSString *dir = [doc stringByAppendingPathComponent:@"lua"];
        [[NSFileManager defaultManager] removeItemAtPath:dir error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];

        NSString *pp = [[NSString alloc ] initWithFormat:@"%@/patch/?.lua;%@/?/init.lua;", dir, dir];
        setenv(LUA_PATH, [pp UTF8String], 1);
    }
    return self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window makeKeyAndVisible];
//    [self creatPatchJson];
   NSString * fileStr = [JWPatchTool creatPatchJson];
    NSLog(@"file str---%@",fileStr);
//    [JWPatchTool requestPatchWithUrl:PATCH_URL];
   
//    [[JWPatchTool sharedInstance]loadLocalPatchWithFileName:"patch.lua"];
    
    
    // Override point for customization after application launch.
    return YES;
}
// 测试本地patch文件

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
