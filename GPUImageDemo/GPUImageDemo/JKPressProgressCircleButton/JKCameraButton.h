//
//  JKCameraButton.h
//  GPUImageDemo
//
//  Created by mac on 2017/11/28.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKCircleProgressView.h"

@protocol JKCameraButtonDelegate <NSObject>

@optional
-(void)capturePhoto;
-(void)captureVideoBegan;
-(void)captureVideoEnded;

@end



@interface JKCameraButton : NSObject

-(instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)showToView:(UIView *)superView;

@property (nonatomic, strong) JKCircleProgressView *progressView;

@property (nonatomic, weak) id<JKCameraButtonDelegate> delegate;
@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, assign) CGFloat timeForCircle;    // time for a circle;
@property (nonatomic, assign) CGFloat timeInterval;     // time interval

@property (nonatomic, assign) BOOL enabled;//user interface enable;

@end
