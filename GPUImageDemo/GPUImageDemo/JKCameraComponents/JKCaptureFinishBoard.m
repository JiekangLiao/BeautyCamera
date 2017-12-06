//
//  JKCaptureFinishBoard.m
//  GPUImageDemo
//
//  Created by mac on 2017/11/30.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "JKCaptureFinishBoard.h"
#import "JKCameraButton.h"

@interface JKCaptureFinishBoard ()<JKCameraButtonDelegate>

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIButton *bilateralButton;
@property (nonatomic, strong) JKCameraButton *captureButton;
@property (nonatomic, strong) UIButton *brightnessButton;


@property (nonatomic, assign) BOOL finish;

@end



@implementation JKCaptureFinishBoard

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(JKCameraButton *)creatCaptureButton{
    if (!_captureButton) {
        CGFloat height = 63;
        _captureButton = [[JKCameraButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2-height/2, CGRectGetHeight(self.frame)/2-height/2, height, height) superView:self];
        _captureButton.delegate = self;
    }
    return _captureButton;
}

-(void)setupSubviews{
    
    [self addSubview:self.bilateralButton];
    [self creatCaptureButton];
    [self addSubview:self.brightnessButton];
    
    [self addSubview:self.cancelButton];
    [self addSubview:self.finishButton];
    [self addSubview:self.shareButton];
    
    
    [self.bilateralButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(45);
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.brightnessButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-45);
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(25);
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(63, 63));
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-25);
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    self.finish = NO;
}

-(UIButton *)bilateralButton{
    if (!_bilateralButton) {
        _bilateralButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bilateralButton setImage:[UIImage imageNamed:@"shoot_exfoliating_n"] forState:UIControlStateNormal];
        [_bilateralButton setImage:[UIImage imageNamed:@"shoot_exfoliating_h"] forState:UIControlStateSelected];
        [_bilateralButton addTarget:self action:@selector(bilateralButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bilateralButton;
}

-(UIButton *)brightnessButton{
    if (!_brightnessButton) {
        _brightnessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_brightnessButton setImage:[UIImage imageNamed:@"shoot_whitening_n"] forState:UIControlStateNormal];
        [_brightnessButton setImage:[UIImage imageNamed:@"shoot_whitening_h"] forState:UIControlStateSelected];
        [_brightnessButton addTarget:self action:@selector(brightnessButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _brightnessButton;
}

//Buffing
-(void)bilateralButtonAction{
    _bilateralButton.selected = !_bilateralButton.selected;
    _brightnessButton.selected = NO;
    if (_bilateralAction) {
        _bilateralAction();
    }
}

//Skin
-(void)brightnessButtonAction{
    _brightnessButton.selected = !_brightnessButton.selected;
    _bilateralButton.selected = NO;
    if (_brightnessAction) {
        _brightnessAction();
    }
}

-(void)setFinish:(BOOL)finish{
    _finish = finish;
    if (!finish) {
        [self.captureButton.progressView setOriginalState];
    }
    self.bilateralButton.hidden /*= self.captureButton.progressView.hidden */= self.brightnessButton.hidden = finish;
    self.cancelButton.hidden =  self.finishButton.hidden = self.shareButton.hidden = !_finish;
    
}

-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"shoot_close_n3"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)finishButton{
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setImage:[UIImage imageNamed:@"shoot_select_n"] forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

-(UIButton *)shareButton{
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"shoot_share_n"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

//cancel
-(void)cancelButtonAction:(UIButton *)sender{
    self.finish = NO;
    if (_cancelBlock) {
        _cancelBlock();
    }
}

//finish
-(void)finishButtonAction:(UIButton *)sender{
    self.finish = NO;
    if (_finishBlock) {
        _finishBlock();
    }
}

//share
-(void)shareButtonAction:(UIButton *)sender{
    self.finish = NO;
    if (_shareBlock) {
        _shareBlock();
    }
}

#pragma mark - Camera button delegate -
//capture photo
-(void)capturePhoto{
    self.finish = YES;
    if (_capturePhotoBlcok) {
        _capturePhotoBlcok();
    }
}

//capture video began
-(void)captureVideoBegan{
    if (_captureVideoBeganBlock) {
        _captureVideoBeganBlock();
    }
}

//capture video ended
-(void)captureVideoEnded{
    self.finish = YES;
    if (_captureVIdeoEndedBlock) {
        _captureVIdeoEndedBlock();
    }
}

-(void)setEnable:(BOOL)enable{
    _enable = enable;
//    self.cancelButton.userInteractionEnabled = _enable;
//    self.finishButton.userInteractionEnabled = _enable;
//    self.shareButton.userInteractionEnabled = _enable;
}

@end
