//
//  JKCameraNavigationBar.h
//  GPUImageDemo
//
//  Created by mac on 2017/11/30.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKCameraNavigationBar : UIView

@property (nonatomic, copy) void(^backBlock)(void);
@property (nonatomic, copy) void(^menuBlock)(void);
@property (nonatomic, copy) void(^transformBlock)(void);

@end
