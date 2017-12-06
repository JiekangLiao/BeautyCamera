//
//  JKCircleProgressView.m
//  GPUImageDemo
//
//  Created by mac on 2017/11/28.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "JKCircleProgressView.h"


@interface JKCircleProgressView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *outLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end


static CGFloat kLineWidth = 5;

@implementation JKCircleProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        _progress = 0;
        
        CGRect frame = self.frame;
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        [self setOriginalState];
        
        self.outLayer = [CAShapeLayer layer];
        CGRect rect = {kLineWidth / 2, kLineWidth / 2,
            frame.size.width - kLineWidth, frame.size.height - kLineWidth};
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        self.outLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.outLayer.lineWidth = kLineWidth;
        self.outLayer.fillColor =  [UIColor clearColor].CGColor;
        self.outLayer.lineCap = kCALineCapRound;
        self.outLayer.path = path.CGPath;
        [self.layer addSublayer:self.outLayer];
        
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor redColor].CGColor;
        self.progressLayer.lineWidth = kLineWidth;
        self.progressLayer.lineCap = kCALineCapRound;
        self.progressLayer.path = path.CGPath;
        self.progressLayer.strokeEnd = 0;
        [self.layer addSublayer:self.progressLayer];
        
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }
    
    return self;
    
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self updateProgressWithProgress:_progress];
}

- (void)updateProgressWithProgress:(CGFloat)prgress {
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:0.2];
    self.progressLayer.strokeEnd = _progress;
    [CATransaction commit];
}

-(void)setImageWithName:(NSString *)name{
    self.imageView.image = [UIImage imageNamed:name];
}

-(void)setOriginalState{
    [self setImageWithName:@"shoot_n"];
}

-(void)setProccessingState{
    [self setImageWithName:@"shoot_play_round_n"];
}

-(void)setEndedState{
    self.progressLayer.strokeEnd = 0;
    _progress = 0;
    [self setImageWithName:@"shoot_select_n"];
}


@end
