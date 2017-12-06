//
//  JKCameraButton.m
//  GPUImageDemo
//
//  Created by mac on 2017/11/28.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "JKCameraButton.h"

@interface JKCameraButton ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGFloat increment;

@end



@implementation JKCameraButton


-(instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView{
    self = [self initWithFrame:frame];
    if (self) {
        [self showToView:superView];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super init];
    
    if (self) {
        
        self.frame = frame;
        _timeForCircle = 10;
        _timeInterval = 0.2;
        _increment = _timeInterval/_timeForCircle;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.5;
        [self.progressView addGestureRecognizer:longPress];
        [self.progressView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)]];
        
    }
    
    return self;
    
}

-(void)showToView:(UIView *)superView{
    [superView addSubview:self.progressView];
}

-(void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    [self.progressView setImageWithName:_imageName];
}

-(JKCircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[JKCircleProgressView alloc]initWithFrame:self.frame];
    }
    return _progressView;
}

-(void)tapPress:(UITapGestureRecognizer *)tap{
    if (self.delegate && [self.delegate respondsToSelector:@selector(capturePhoto)]) {
        [self.delegate capturePhoto];
    }
    
}

-(void)longPress:(UIGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self startCapture];
    }else if (longPress.state == UIGestureRecognizerStateEnded){
        [self stopCapture];
    }
    
}

-(void)startCapture{
    [self.progressView setProccessingState];
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureVideoBegan)]) {
        [self.delegate captureVideoBegan];
    }
    [self start];
}

-(void)stopCapture{
    [self.progressView setEndedState];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureVideoEnded)]) {
        [self.delegate captureVideoEnded];
    }
    [self end];
}

-(void)start{
    [self.timer fire];
}

-(void)pause{
    
    if (![_timer isValid]) {
        return ;
    }
    [_timer setFireDate:[NSDate distantFuture]];
    
}

-(void)resume{
    
    if (![_timer isValid]) {
        return ;
    }
    //[self setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [_timer setFireDate:[NSDate date]];
    
}

-(void)end{
    [_timer invalidate];
    _timer = nil;
}

-(NSTimer *)timer{
    if (!_timer) {
        _timer =  [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                   target:self
                                                 selector:@selector(updateProgress)
                                                 userInfo:nil
                                                  repeats:YES];
    }
    return _timer;
}

-(void)updateProgress{
    self.progressView.progress += _increment;
}

-(void)setTimeForCircle:(CGFloat)timeForCircle{
    if (timeForCircle <= 0) {
        _timeForCircle = 10;
    }
    _timeForCircle = timeForCircle;
    _increment = _timeInterval / _timeForCircle;
}

-(void)setTimeInterval:(CGFloat)timeInterval{
    if (_timeForCircle == 0) {
        _timeForCircle = 10;
    }
    _timeInterval = timeInterval;
    _increment = _timeInterval / _timeForCircle;
}


-(void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    self.progressView.userInteractionEnabled = _enabled;
}


@end
