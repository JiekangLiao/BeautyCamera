//
//  JKCircleProgressView.h
//  GPUImageDemo
//
//  Created by mac on 2017/11/28.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JKCircleProgressView : UIView

- (void)setImageWithName:(NSString *)name;
- (void)updateProgressWithNumber:(NSUInteger)number;

-(void)setOriginalState;
-(void)setProccessingState;
-(void)setEndedState;

@property (nonatomic, assign) CGFloat progress;

@end
