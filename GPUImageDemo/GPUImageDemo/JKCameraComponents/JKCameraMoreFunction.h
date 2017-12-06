//
//  JKCameraMoreFunction.h
//  GPUImageDemo
//
//  Created by mac on 2017/12/4.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, JKCameraFunctionType) {
    JKCameraFunctionTypeSizeOfPicture,//画幅
    JKCameraFunctionTypeTouchCapture,//触摸拍摄
    JKCameraFunctionTypeDelayCapture,//延时拍摄
    JKCameraFunctionTypeFlash,//闪烁
    JKCameraFunctionTypeDarknessCorner,//暗角
};

@interface JKCameraMoreFunctionModel : NSObject

@property (nonatomic, copy) NSString *imageNameNormal;
@property (nonatomic, copy) NSString *imageNameHighlight;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) JKCameraFunctionType type;

@end


@interface JKCameraMoreCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JKCameraMoreFunctionModel *model;
@property (nonatomic, assign) BOOL isSelected;

@end


@class JKCameraMoreFunction;
@protocol JKCameraMoreFunctionDelegate <NSObject>

-(void)cameraMoreFunctionBoard:(JKCameraMoreFunction *)moreFunctionBoard didSelectItemWithModel:(JKCameraMoreFunctionModel *)model;

@end


@interface JKCameraMoreFunction : UICollectionView<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) id<JKCameraMoreFunctionDelegate> moreFunctionBoardDelegate;
@property (nonatomic, strong) NSMutableArray *datas;

@end
