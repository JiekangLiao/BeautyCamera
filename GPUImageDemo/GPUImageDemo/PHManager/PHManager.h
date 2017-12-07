//
//  PHManager.h
//  GPUImageDemo
//
//  Created by mac on 2017/12/7.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@protocol PHManagerDelegate <NSObject>

-(void)saveimageFinish;
-(void)saveImageFailure;

@end


@interface PHManager : NSObject

@property (nonatomic, weak) id<PHManagerDelegate> delegate;

/**
 Save iamge

 @param image image
 @param collectionName photos collection name
 */
- (void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName;


/**
 Get photos collection with name

 @param collectionName collection name
 @return collection
 */
- (PHAssetCollection *)getPhotoCollectionWithCollectionName:(NSString *)collectionName;

@end
