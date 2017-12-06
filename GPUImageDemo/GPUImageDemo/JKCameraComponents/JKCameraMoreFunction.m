//
//  JKCameraMoreFunction.m
//  GPUImageDemo
//
//  Created by mac on 2017/12/4.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "JKCameraMoreFunction.h"



@implementation JKCameraMoreFunctionModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

-(NSString *)description{
    return [NSString stringWithFormat:@"正常图片：%@ 高亮图片：%@ 名称：%@ 选中：%d 操作类型：%lu", self.imageNameNormal, self.imageNameHighlight, self.title, self.isSelected, self.type];
}

@end



@implementation JKCameraMoreCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubvies];
    }
    return self;
}

-(void)setupSubvies{
    [self.contentView addSubview:self.button];
    [self.contentView addSubview:self.titleLabel];
}

-(UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 50, WIDTH/5, 47);
        _button.userInteractionEnabled = NO;
        
    }
    return _button;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_button.frame), CGRectGetWidth(self.frame), 20)];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(void)setModel:(JKCameraMoreFunctionModel *)model{
    if (_model != model) {
        _model = model;
    }
    [_button setImage:[UIImage imageNamed:_model.imageNameNormal] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:_model.imageNameHighlight] forState:UIControlStateSelected];
    _titleLabel.text = _model.title;
    self.isSelected = _model.isSelected;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    _titleLabel.textColor = isSelected ? [UIColor redColor] : [UIColor whiteColor];
    _button.selected = _isSelected;
//    _imageView.image = isSelected ? [UIImage imageNamed:_model.imageNameHighlight] : [UIImage imageNamed:_model.imageNameNormal];
}

@end



@interface JKCameraMoreFunction ()


@end


static NSString *const cellID = @"cellId";

@implementation JKCameraMoreFunction

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(WIDTH/5, 167);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _datas = [NSMutableArray new];
        NSMutableArray *array = [NSMutableArray new];
        self.dataSource = self;
        self.delegate = self;
        [array addObject:@{@"title":@"画幅", @"imageNameNormal":@"shoot_draw1_n", @"imageNameHighlight":@"shoot_draw1_h", @"type":@(JKCameraFunctionTypeSizeOfPicture)}];
        [array addObject:@{@"title":@"触屏拍摄", @"imageNameNormal":@"shoot_touch_screen_n", @"imageNameHighlight":@"shoot_touch_screen_h", @"type":@(JKCameraFunctionTypeTouchCapture)}];
        [array addObject:@{@"title":@"延时拍摄", @"imageNameNormal":@"shoot_time-lapse_n", @"imageNameHighlight":@"shoot_time-lapse_h", @"type":@(JKCameraFunctionTypeDelayCapture)}];
        [array addObject:@{@"title":@"闪光灯", @"imageNameNormal":@"shoot_flash_n", @"imageNameHighlight":@"shoot_flash_h", @"type":@(JKCameraFunctionTypeFlash)}];
        [array addObject:@{@"title":@"暗角", @"imageNameNormal":@"shoot_dark_corner_n", @"imageNameHighlight":@"shoot_dark_corner_h", @"type":@(JKCameraFunctionTypeDarknessCorner)}];
        
        for (NSDictionary *dict in array) {
            JKCameraMoreFunctionModel *model = [JKCameraMoreFunctionModel new];
            [model setValuesForKeysWithDictionary:dict];
            [_datas addObject:model];
        }
        
        [self registerClass:[JKCameraMoreCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        
    }
    return self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _datas.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JKCameraMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    JKCameraMoreFunctionModel *model = _datas[indexPath.item];
    cell.model = model;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    JKCameraMoreFunctionModel *model = _datas[indexPath.item];
    model.isSelected = !model.isSelected;
    dispatch_async(dispatch_get_main_queue(), ^{
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
    if (self.moreFunctionBoardDelegate && [self.moreFunctionBoardDelegate respondsToSelector:@selector(cameraMoreFunctionBoard:didSelectItemWithModel:)]) {
        [self.moreFunctionBoardDelegate cameraMoreFunctionBoard:self didSelectItemWithModel:model];
    }
}


@end
