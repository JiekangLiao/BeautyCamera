//
//  JKCameraNavigationBar.m
//  GPUImageDemo
//
//  Created by mac on 2017/11/30.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "JKCameraNavigationBar.h"

@interface JKCameraNavigationBar ()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *midleButton;
@property (nonatomic, strong) UIButton *rightButton;

@end



@implementation JKCameraNavigationBar

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    [self addSubview:self.leftButton];
    [self addSubview:self.midleButton];
    [self addSubview:self.rightButton];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(31, 31));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.midleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(31, 31));
        make.centerY.equalTo(self.mas_centerY);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(31, 31));
        make.centerY.equalTo(self.mas_centerY);
    }];
}

-(UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftButton setImage:[UIImage imageNamed:@"shoot_back_n"] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

-(UIButton *)midleButton{
    if (!_midleButton) {
        _midleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_midleButton setImage:[UIImage imageNamed:@"shoot_more_n"] forState:UIControlStateNormal];
//        [_midleButton setImage:[UIImage imageNamed:@"shoot_more_h"] forState:UIControlStateSelected];
        [_midleButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _midleButton;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setImage:[UIImage imageNamed:@"shoot_toggle_n"] forState:UIControlStateNormal];
//        [_rightButton setImage:[UIImage imageNamed:@"shoot_toggle_h"] forState:UIControlStateSelected];
        [_rightButton addTarget:self action:@selector(transformCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

-(void)backAction:(UIButton *)sender{
    if (_backBlock) {
        _backBlock();
    }
}

-(void)menuAction:(UIButton *)sender{
//    _midleButton.selected = !_midleButton.selected;
    if (_menuBlock) {
        _menuBlock();
    }
}

-(void)transformCameraAction:(UIButton *)sender{
//    _rightButton.selected = !_rightButton.selected;
    if (_transformBlock) {
        _transformBlock();
    }
}



@end
