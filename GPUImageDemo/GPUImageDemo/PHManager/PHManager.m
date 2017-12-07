//
//  PHManager.m
//  GPUImageDemo
//
//  Created by mac on 2017/12/7.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "PHManager.h"

@implementation PHManager

//Save image in collection，and permission.
- (void)saveImage:(UIImage *)image assetCollectionName:(NSString *)collectionName {
    
    // 1. Get photos Collection permission status of current application.
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    
    // 2. Judge the status of permission.
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        
        // 2.1 Save image, if status is has permission.
        [self saveImage:image toCollectionWithName:collectionName];
        
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) { // Return to user, if not allow permission.
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // Save image, if user selected allow
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImage:image toCollectionWithName:collectionName];
            }
        }];
        
    } else {
        
        //        [SVProgressHUD showWithStatus:@"请在设置界面, 授权访问相册"];
    }
}

// save image to collection
- (void)saveImage:(UIImage *)image toCollectionWithName:(NSString *)collectionName {
    
    // 1. Get collection library object.
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
    // 2. Called changeBlock
    [library performChanges:^{
        
        // 2.1 Create a collection changge request.
        PHAssetCollectionChangeRequest *collectionRequest;
        
        // 2.2 Pull out the collection with specify name
        PHAssetCollection *assetCollection = [self getPhotoCollectionWithCollectionName:collectionName];
        
        // 2.3 Judge. Whether the album exists
        if (assetCollection) { // If exists, use current collection create a request.
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        } else { // Else, create a new collection request.
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName];
        }
        
        // 2.4 On the basis of the image argument, create asset change request.
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        // 2.4 Create a object placeholder.
        PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
        
        // 2.5 Adds a placeholder to the album request
        [collectionRequest addAssets:@[placeholder]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        
        
        // 3. If the error is wrong, the statement is not successful
        if (error) {
            // [SVProgressHUD showErrorWithStatus:@"保存失败"];
            dispatch_async(dispatch_get_main_queue(), ^{
                //            [_captureButton setEnabled:YES];
                //            self.finishBoard.enable = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(saveImageFailure)]) {
                    [self.delegate saveImageFailure];
                }
            });
            
        } else {
            // [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                //            [_captureButton setEnabled:YES];
                //            self.finishBoard.enable = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(saveimageFinish)]) {
                    [self.delegate saveimageFinish];
                }
            });
            
        }
        
    }];
}

- (PHAssetCollection *)getPhotoCollectionWithCollectionName:(NSString *)collectionName {
    
    // 1. Create Fetch result with search collection
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. Traverse the search collection and take out the corresponding album
    for (PHAssetCollection *assetCollection in result) {
        
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    
    return nil;
}


@end
