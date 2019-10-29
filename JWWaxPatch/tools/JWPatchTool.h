//
//  JWPatchTool.h
//  JWWaxPatch
//
//  Created by jiang on 2019/10/29.
//  Copyright © 2019 jarvis. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWPatchTool : NSObject

+ (JWPatchTool *)sharedInstance;


/// 加载本地文件
/// @param fileName 文件名例如："patch.lua"
- (void)loadLocalPatchWithFileName:(char *)fileName;


/// 根据patch.zip 创建需要上传的json文件 放在temp文件夹下 返回值为存放路劲
+ (NSString *)creatPatchJson;


/// 根据路劲获取patch
/// @param urlStr 请求地址
+ (void)requestPatchWithUrl:(NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
