//
//  SandBoxProcessTool.m
//  OfficeTest
//
//  Created by suruikeji on 2016/11/25.
//  Copyright © 2016年 com.SuRuikeji.fany. All rights reserved.
//

#import "SandBoxProcessTool.h"
#import <UIKit/UIKit.h>

@implementation SandBoxProcessTool

#pragma mark - 增加 -

/**
 新建文件，并写入数据
 
 @param data 需要写入的数据
 @param name 文件名
 @return 创建成功返回路径，创建失败返回nil
 @filePath 文件路径
 */
+ (NSString *)newFileWithData:(NSData *)data fileName:(NSString *)name atPath:(NSString *)path{
    //获取沙盒
//    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [path stringByAppendingPathComponent:name];
    //把数据写入新文件所在路径（path）
//    BOOL b = [fileManager createFileAtPath:filePath contents:data attributes:nil];
    BOOL b = [data writeToFile:filePath atomically:YES];
    return b ? filePath : nil;
}


/**
 新建文件夹
 
 @param folderName 新建文件夹名
 @return 新建的文件夹路径,如果创建失败返回nil
 */
+ (NSString *)newFolderInSandbox:(NSString *)folderName atPath:(NSString *)path{
    //获取沙盒
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //新建空文件夹newFolder
    NSString *newFolder = [path stringByAppendingPathComponent:folderName];
    BOOL b = [fileManager createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];
    return b ? newFolder : nil;
}

#pragma mark - 删除 -

/**
 删除文件或目录

 @param path 文件或目录路径
 @return 如果删除失败返回错误信息 NSError*
 */
+ (NSError *)deleteItemWithPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL b = [fileManager removeItemAtPath:path error:&error];
    return b ? nil : error;
}

#pragma mark - 查询目录或文件 -
/**
 获取某个目录下的所有文件（或文件夹，不包括它们的下一级item）

 @param path 目录的路径
 @return 该目录下的所有文件 @[ @{path_Key : path_Value, objectName_Key : objectName_Value, selected_Key : selected_Value, isFolder_Key : isFolder_Value, } ]
 */
+(NSMutableArray *)getItemsWithPath:(NSString *)path{
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    if (![defaultManager fileExistsAtPath:path]) {
        [defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"\n create directory finish ! \n");
    }
    //获取目录下的所有文件列表：
    NSArray *fileList = [defaultManager contentsOfDirectoryAtPath:path error:nil];
    NSLog(@"%@目录下的文件列表如下：=====》\n %@ \n", path, fileList);
    NSMutableArray *items = [NSMutableArray new];
    for (id obj in fileList) {
        NSString *str = [NSString stringWithFormat:@"%@", obj];
        NSString *pt = [path stringByAppendingPathComponent:str];
        BOOL isDir;
        [defaultManager fileExistsAtPath:pt isDirectory:&isDir];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:pt forKey:@"path"];
        [dict setObject:str forKey:@"objectName"];
        [dict setObject:@0 forKey:@"selected"];
        [dict setObject:@(isDir) forKey:@"isFolder"];
        [items addObject:dict];
    }
    return items;
}

/**
 获取某个目录下的所有文件（或文件夹，不包括它们的下一级item）,并过滤掉目录，只显示文件
 
 @param path 目录的路径
 @return 该目录下的所有文件 @[ @{path_Key : path_Value, objectName_Key : objectName_Value, selected_Key : selected_Value, isFolder_Key : isFolder_Value, } ]
 */
+(NSMutableArray *)getItemsClearDirectoryWithPath:(NSString *)path{
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    if (![defaultManager fileExistsAtPath:path]) {
        [defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"\n create directory finish ! \n");
    }
    //获取目录下的所有文件列表：
    NSArray *fileList = [defaultManager contentsOfDirectoryAtPath:path error:nil];
    NSLog(@"%@目录下的文件列表如下：=====》\n %@ \n", path, fileList);
    NSMutableArray *items = [NSMutableArray new];
    for (id obj in fileList) {
        NSString *str = [NSString stringWithFormat:@"%@", obj];
        if ([str isEqualToString:@".DS_Store"]) {
            continue;
        }
        NSString *pt = [path stringByAppendingPathComponent:str];
        BOOL isDir;
        [defaultManager fileExistsAtPath:pt isDirectory:&isDir];
        if (isDir) {
            continue;
        }
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:pt forKey:@"path"];
        [dict setObject:str forKey:@"objectName"];
        [dict setObject:@0 forKey:@"selected"];
        [dict setObject:@(isDir) forKey:@"isFolder"];
        [items addObject:dict];
    }
    return items;
}

/**
 获取沙盒目录

 @param u 沙盒目录类型  见 》》》枚举“SandBoxDirectoryType”
 @return 沙盒路径，如果枚举类型不存在则返回 nil。
 */
NSString * getSandBoxDirectoryWithType(SandBoxDirectoryType u){
    
    switch (u) {
            
        case SandBoxDirectoryTypeHome:
            return NSHomeDirectory();
            break;
            
        case SandBoxDirectoryTypeDocuments:
            return NSHomeDirectory();
            break;
            
        case SandBoxDirectoryTypeLibrary:
            return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
            break;
            
        case SandBoxDirectoryTypeCaches:
            return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            break;
            
        case SandBoxDirectoryTypeCachesSkydrive:
        {
            NSString *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            NSString *skydrive = [caches stringByAppendingPathComponent:SkydriveDirectory];
            return skydrive;
        }
            break;
            
        case SandBoxDirectoryTypePreference:
            return NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES)[0];
            break;
            
        case SandBoxDirectoryTypeTemporary:
            return NSTemporaryDirectory();
            break;

        default:
            return nil;
            break;
            
    }
    
}


/**
 检测路径是否存在

 @param path 路径
 @return 是否存在，yes是，no否
 */
+(BOOL)checkPathIsExist:(NSString *)path{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    return [defaultManager fileExistsAtPath:path];
}



+(NSString *)stringSizeWithIntegerByte:(NSInteger)byte{
    CGFloat f;
    NSString *sizeString;
    if (byte >= 1024*1024){
        f = byte/1024.0f/1024.0f;
        sizeString = [NSString stringWithFormat:@"%.2fMB", f];
    } else if (byte>=1024) {
        f = byte/1024.0f;
        sizeString = [NSString stringWithFormat:@"%.2fKB", f];
    }else{
        f = byte*1.0f;
        sizeString = [NSString stringWithFormat:@"%.2fB", f];
    }
    return sizeString;
}

/**
 计算文件大小size

 @param filePath 文件路径
 @return 文件大小size
 */
NSInteger fileSizeAtPath(NSString* filePath){
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end
