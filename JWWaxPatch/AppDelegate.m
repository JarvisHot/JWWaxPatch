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
#import <AFNetworking/AFNetworking.h>
#import "ZipArchive.h"
#import "NSDictionary+json.h"
#import "RSATools.h"
#import "wax.h"
#import "ViewController.h"

NSString *const RSAPrivateKey1 = @"-----BEGIN PRIVATE KEY-----\nMIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKrEc9IjNjcU5/su\nq91No/0oJ3XAOjFzovk0878vqD5JivxMbAA5gIsdZbtsFk15p9GjpWgDUlHfDTEy\nF0XGrN1bgapDHrqud4gJ+2RzuOrMo3/WcM1faRXal/pGJefTJpJsk6rD9fnFF060\nY48tMP39aYUUKVH4Y3hod4BTv1cfAgMBAAECgYB+7ADBoNY83lcFhEzM8VX/ZQbf\nJ/6Ynr/0xXydDwjXMsYQe6SSDisSOslQIif5cYBf+meIBV/75fLiK77MZ7w2m2YY\ndw1o3w80vkjRxnQmI7OLBsXj7S67q5Z3cgg+JL2Zl7DKiJi0G7iikKbUIDnY9CjR\nJ97Q/pE3MLuDLyPGoQJBANOqci6LVfcAwcQNTtWBBV8iZ11/wgBhQlXu2PlYEce7\n1phFkRvGQTthgEyU9587le7eFkre0XPPTt0WHtKMikcCQQDOiQbsjMAxbMTV95YU\nP7ah+lE7LvuxgiamRlR584SOg4nSIJM42xzSrMlCPkJALQvnumEbjT5XufY39bx5\nwGBpAkAvRSVy15M/MmATlJVCgSnd8ST8cIe25gGWh1zVcqGl5YErSH37oe73f/LT\nJ4GVgg0d52M7HT/RiT6niUUg6FoJAkAz5DW7JTn8sQlbgRNSDxgB5nSWXB2c4ch4\nKl97LHX3oJD2HH0g4dyCCiue2ymmGitNk4RmebxaKjz0nmc2Z+FRAkAsg33dfDpH\n0yEMl7WxDoNkLcWf99Mq76bZZGDapvly0vGy8R1ThWRhP0dWJcLm3JIFHHE7W1Zr\nIlcp1unqlF/l\n-----END PRIVATE KEY-----";
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window makeKeyAndVisible];
//   NSString * fileStr = [JWPatchTool creatPatchJson];
//    NSLog(@"file str---%@",fileStr);
    [JWPatchTool requestPatchWithUrl:PATCH_URL AndRootViewController:[[UINavigationController alloc]initWithRootViewController:[ViewController new]]];
    
    
//    [JWPatchTool loadLocalPatchWithFileName:"patch.lua"];
    
    NSLog(@"进入到application下一步");
    // Override point for customization after application launch.
    return YES;
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
