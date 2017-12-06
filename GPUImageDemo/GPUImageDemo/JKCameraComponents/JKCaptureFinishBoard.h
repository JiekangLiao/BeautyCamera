//
//  JKCaptureFinishBoard.h
//  GPUImageDemo
//
//  Created by mac on 2017/11/30.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKCaptureFinishBoard : UIView

@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^finishBlock)(void);
@property (nonatomic, copy) void(^shareBlock)(void);

@property (nonatomic, copy) void(^capturePhotoBlcok)(void);
@property (nonatomic, copy) void(^captureVideoBeganBlock)(void);
@property (nonatomic, copy) void(^captureVIdeoEndedBlock)(void);

@property (nonatomic, copy) void(^bilateralAction)(void);
@property (nonatomic, copy) void(^brightnessAction)(void);

@property (nonatomic, assign) BOOL enable;

@end
