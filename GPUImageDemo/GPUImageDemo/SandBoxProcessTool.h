//
//  SandBoxProcessTool.h
//  OfficeTest
//
//  Created by suruikeji on 2016/11/25.
//  Copyright © 2016年 com.SuRuikeji.fany. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SkydriveDirectory @"SkydriveDirectory"
/**
 沙盒目录：0-根； 1-文档； 2-库； 3-缓存； 4-偏好设置； 5-临时
 */
typedef NS_ENUM(NSUInteger, SandBoxDirectoryType) {
    
    //沙盒根目录
    SandBoxDirectoryTypeHome = 0,
    
    //沙盒文档目录
    SandBoxDirectoryTypeDocuments,
    
    //沙盒库目录
    SandBoxDirectoryTypeLibrary,//库
    SandBoxDirectoryTypeCaches,//缓存
        SandBoxDirectoryTypeCachesSkydrive,//缓存-云盘目录
    SandBoxDirectoryTypePreference,//偏好设置
    
    //沙盒临时目录
    SandBoxDirectoryTypeTemporary
};

@interface SandBoxProcessTool : NSObject

#pragma mark - 增加 -

/**
 新建文件，并写入数据
 
 @param data 需要写入的数据
 @param name 文件名
 @return 创建成功返回路径，创建失败返回nil
 @filePath 文件路径
 */
+ (NSString *)newFileWithData:(NSData *)data fileName:(NSString *)name atPath:(NSString *)path;


/**
 新建文件夹
 
 @param folderName 新建文件夹名
 @return 新建的文件夹路径,如果创建失败返回nil
 */
+ (NSString *)newFolderInSandbox:(NSString *)folderName atPath:(NSString *)path;

#pragma mark - 删除 -

/**
 删除文件或目录
 
 @param path 文件或目录路径
 @return 如果删除失败返回错误信息 NSError*
 */
+ (NSError *)deleteItemWithPath:(NSString *)path;


#pragma mark - 查询 -
/**
 获取某个目录下的所有文件（或文件夹，不包括它们的下一级item）
 
 @param path 目录的路径
 @return 该目录下的所有文件 @[ @{path_Key : path_Value, objectName_Key : objectName_Value, selected_Key : selected_Value, isFolder_Key : isFolder_Value, } ]
 */
+(NSMutableArray *)getItemsWithPath:(NSString *)path;

/*
获取某个目录下的所有文件（或文件夹，不包括它们的下一级item）,并过滤掉目录，只显示文件

@param path 目录的路径
@return 该目录下的所有文件 @[ @{path_Key : path_Value, objectName_Key : objectName_Value, selected_Key : selected_Value, isFolder_Key : isFolder_Value, } ]
*/
+(NSMutableArray *)getItemsClearDirectoryWithPath:(NSString *)path;

/**
 获取沙盒目录
 
 @param u 沙盒目录类型  见 》》》枚举“SandBoxDirectoryType”
 @return 沙盒路径，如果枚举类型不存在则返回 nil。
 */
NSString * getSandBoxDirectoryWithType(SandBoxDirectoryType u);

/**
 检测路径是否存在
 
 @param path 路径
 @return 是否存在，yes是，no否
 */
+(BOOL)checkPathIsExist:(NSString *)path;


/**
 计算文件大小

 @param byte 字节
 @return 文件大小（B，KB，MB）
 */
+(NSString *)stringSizeWithIntegerByte:(NSInteger)byte;

/**
 计算文件大小size
 
 @param filePath 文件路径
 @return 文件大小size
 */
NSInteger fileSizeAtPath(NSString* filePath);



@end
