//
//  ViewController.m
//  GPUImageDemo
//
//  Created by mac on 2017/11/27.
//  Copyright © 2017年 wsj. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import <Photos/Photos.h>
//#import "JKCameraButton.h"
#import "SandBoxProcessTool.h"

#import "JKCaptureFinishBoard.h"
#import "JKCameraNavigationBar.h"
#import "JKCameraMoreFunction.h"
#import "PHManager.h"
#import "SystemInvestigator.h"




typedef NS_ENUM(NSUInteger, SliderResponder) {
    SliderResponderBuffing,
    SliderResponderBrightness,
};

typedef NS_ENUM(NSUInteger, SizeOfPictureType) {
    SizeOfPictureType16x9 = 0,
    SizeOfPictureType4x3,
    SizeOfPictureType1x1,
};

@interface ViewController ()<UIGestureRecognizerDelegate, JKCameraMoreFunctionDelegate, PHManagerDelegate>

@property (nonatomic, strong) GPUImageView *captureVideoPreview;//录像预览
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;//视频写入管理器

@property (nonatomic, strong) GPUImageStillCamera *photoCamera;//照片

//@property (nonatomic, strong) JKCameraButton *captureButton;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic, strong) JKCameraNavigationBar *navigationBar;

@property (nonatomic, strong) JKCaptureFinishBoard *finishBoard;
@property (nonatomic, strong) JKCameraMoreFunction *moreFunctionBoard;

@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, assign) SliderResponder sliderResponder;

@property (nonatomic, strong) GPUImageBilateralFilter *bilateralFilter;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;

@property (nonatomic, strong) GPUImageCropFilter *cropFilter;

@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;


@property (nonatomic, assign) CGFloat intensity;

@property (nonatomic, assign) SizeOfPictureType sizeType;
@property (nonatomic, assign) BOOL captureWhenTouch;
@property (nonatomic, assign) BOOL delayCapture;
@property (nonatomic, assign) AVCaptureTorchMode captureLightMode;

@property (nonatomic, strong) PHManager *phManager;

@end

@implementation ViewController{
    NSString *pathToMovie;
    CGFloat bilateralMaxValue;
    CGFloat beautifyMaxValue;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    NSArray *documentObjects = [SandBoxProcessTool getItemsWithPath:getSandBoxDirectoryWithType(SandBoxDirectoryTypeDocuments)];
//    NSLog(@"%@",documentObjects);
    // Do any additional setup after loading the view.
    _intensity = 0.5;
    bilateralMaxValue = 12;
    beautifyMaxValue = 0.2;
    self.sizeType = SizeOfPictureType16x9;
    [self configurationPhotoCamera];
    
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.finishBoard];
    [self.view addSubview:self.moreFunctionBoard];
    self.moreFunctionBoard.hidden = YES;
    [self.view addSubview:self.slider];
    self.slider.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
//    _captureButton = [self creatCaptureButton];
}

-(PHManager *)phManager{
    if (!_phManager) {
        _phManager = [[PHManager alloc]init];
        _phManager.delegate = self;
    }
    return _phManager;
}

-(GPUImageFilterGroup *)filterGroup{
    if (!_filterGroup) {
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:self.cropFilter];
//        GPUImageHarrisCornerDetectionFilter *filter = [[GPUImageHarrisCornerDetectionFilter alloc]init];
//        GPUImageCrosshairGenerator *filter = [[GPUImageCrosshairGenerator alloc]init];
        GPUImageTransformFilter *filter = [[GPUImageTransformFilter alloc]init];
        [self addGPUImageFilter:filter];
    }
    return _filterGroup;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.moreFunctionBoard] || [touch.view isDescendantOfView:self.finishBoard] || [touch.view isDescendantOfView:self.navigationBar]) {
        return NO;
    }
    return YES;
    
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    if (_moreFunctionBoard.hidden) {//当前隐藏了更多功能板
        if (_captureWhenTouch) {
            [self capturePhoto];
        }
    }else{//当前显示了更多功能板
        [self ShowHiddenBoardAction];
    }
}

-(void)ShowHiddenBoardAction{
    self.moreFunctionBoard.hidden = !self.moreFunctionBoard.hidden;
    self.finishBoard.hidden = !self.moreFunctionBoard.hidden;
    if (self.filter) {
        self.slider.hidden = !self.moreFunctionBoard.hidden;
    }
}

-(GPUImageBilateralFilter *)bilateralFilter{
    if (!_bilateralFilter) {
        _bilateralFilter = [[GPUImageBilateralFilter alloc]init];
        _bilateralFilter.distanceNormalizationFactor = _intensity*bilateralMaxValue;
    }
    return _bilateralFilter;
}

-(GPUImageBrightnessFilter *)brightnessFilter{
    if (!_brightnessFilter) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        _brightnessFilter.brightness = _intensity*beautifyMaxValue;
    }
    return _brightnessFilter;
}

-(JKCameraNavigationBar *)navigationBar{
    if (!_navigationBar) {
        _navigationBar = [[JKCameraNavigationBar alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 73+20)];
        __weak typeof(self) weakSelf = self;
        _navigationBar.backBlock = ^{// back
            
        };
        _navigationBar.menuBlock = ^{// menu
            [weakSelf ShowHiddenBoardAction];
        };
        _navigationBar.transformBlock = ^{//transform camera position
            [weakSelf.photoCamera rotateCamera];
        };
    }
    return _navigationBar;
}

-(JKCameraMoreFunction *)moreFunctionBoard{
    if (!_moreFunctionBoard) {
        _moreFunctionBoard = [[JKCameraMoreFunction alloc]initWithFrame:self.finishBoard.frame collectionViewLayout:[UICollectionViewFlowLayout new]];
        _moreFunctionBoard.moreFunctionBoardDelegate = self;
    }
    return _moreFunctionBoard;
}

-(void)cameraMoreFunctionBoard:(JKCameraMoreFunction *)moreFunctionBoard didSelectItemWithModel:(JKCameraMoreFunctionModel *)model{
    
    JKCameraFunctionType type = model.type;
    
    switch (type) {
            
        case JKCameraFunctionTypeSizeOfPicture:
        {
            if (_sizeType == SizeOfPictureType1x1) {
                _sizeType = SizeOfPictureType16x9;
            }else{
                _sizeType += 1;
            }
            model.isSelected = NO;
            
            
            switch (_sizeType) {
                case SizeOfPictureType16x9:
                    model.imageNameNormal = @"shoot_draw1_n";
                    break;
                    
                case SizeOfPictureType4x3:
                    model.imageNameNormal = @"shoot_draw2_n";
                    break;
                    
                case SizeOfPictureType1x1:
                    model.imageNameNormal = @"shoot_draw3_n";
                    break;
                    
                default:
                    model.imageNameNormal = @"shoot_draw1_n";
                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger item = [moreFunctionBoard.datas indexOfObject:model];
                [moreFunctionBoard reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:0]]];
                [self setSizeType:_sizeType];
            });
            
        }
            break;
        
        case JKCameraFunctionTypeTouchCapture:
            _captureWhenTouch = !_captureWhenTouch;
            break;
            
        case JKCameraFunctionTypeDelayCapture:
            _delayCapture = !_delayCapture;
            break;
            
        case JKCameraFunctionTypeFlash:{
            if (_photoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.isSelected = NO;
                    NSInteger item = [moreFunctionBoard.datas indexOfObject:model];
                    [moreFunctionBoard reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:0]]];
                });
                _captureLightMode = AVCaptureTorchModeOff;
            }else{
                _captureLightMode = !_captureLightMode;
            }
        }
            break;
            
        case JKCameraFunctionTypeDarknessCorner:
            
            if (model.isSelected) {
                [_photoCamera removeAllTargets];
                GPUImageVignetteFilter *vignetteFilter = [[GPUImageVignetteFilter alloc]init];
                [_photoCamera addTarget:vignetteFilter];
                [vignetteFilter addTarget:_captureVideoPreview];
            }else{
                [_photoCamera removeAllTargets];
                [_photoCamera addTarget:_captureVideoPreview];
            }
            
            break;
            
        default:
            
            break;
    }
}

-(void)setSizeType:(SizeOfPictureType)sizeType{
    _sizeType = sizeType;
//    _photoCamera.captureSessionPreset = model.isSelected ? AVCaptureSessionPreset640x480 : AVCaptureSessionPresetHigh;

    CGRect frame;
    switch (self.sizeType) {
            
        case SizeOfPictureType16x9:{
            frame = CGRectMake(0.0, 0.0, 1.0,1.0);
            _photoCamera.captureSessionPreset = AVCaptureSessionPresetHigh;
        }
            break;
            
        case SizeOfPictureType4x3:{
            frame = CGRectMake(0.0, 0.0, 1.0,WIDTH/HEIGHT/4*3);
            _photoCamera.captureSessionPreset = AVCaptureSessionPreset640x480;
        }
            break;
            
        case SizeOfPictureType1x1:{
            frame = CGRectMake(0.0, 0.0, 1.0, WIDTH/HEIGHT);
            _photoCamera.captureSessionPreset = AVCaptureSessionPresetPhoto;
        }
            break;
            
        default:{
            frame = CGRectMake(0.0, 0.0, 1.0, 1.0);
            _photoCamera.captureSessionPreset = AVCaptureSessionPresetHigh;
        }
            break;
            
    }
    //stillcamera -> filter -> cropfilter ->filterview
    self.cropFilter.cropRegion = frame;
}

-(GPUImageCropFilter *)cropFilter{
    if (!_cropFilter) {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.0, 1.0,1)];
    }
    return _cropFilter;
}

-(void)captureFlashWithMode:(AVCaptureTorchMode)mode{
    
    if (_photoCamera.inputCamera.position == AVCaptureDevicePositionBack) {
        [_photoCamera.inputCamera lockForConfiguration:nil];
        [_photoCamera.inputCamera setTorchMode:mode];
        [_photoCamera.inputCamera unlockForConfiguration];
//        if () {
//            [_photoCamera.inputCamera lockForConfiguration:nil];
//            [_photoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
////            [_photoCamera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
//            [_photoCamera.inputCamera unlockForConfiguration];
//        }else{
//            [_photoCamera.inputCamera lockForConfiguration:nil];
//            [_photoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
//            [_photoCamera.inputCamera unlockForConfiguration];
//        }
        
    }else{
        NSLog(@"当前使用前置摄像头,未能开启闪光灯");
    }
    
}

-(JKCaptureFinishBoard *)finishBoard{
    if (!_finishBoard) {
        _finishBoard = [[JKCaptureFinishBoard alloc]initWithFrame:CGRectMake(0, HEIGHT-167, WIDTH, 167)];
        __weak typeof(self) weakSelf = self;
        _finishBoard.cancelBlock = ^{//record video cancel
            
        };
        _finishBoard.finishBlock = ^{//record video finish
            
        };
        _finishBoard.shareBlock = ^{//share video
            
        };
        _finishBoard.capturePhotoBlcok = ^{//capture photo
            [weakSelf capturePhoto];
        };
        _finishBoard.captureVideoBeganBlock = ^{//capture video begin
            [weakSelf captureVideoBegan];
        };
        _finishBoard.captureVIdeoEndedBlock = ^{//capture video end
            [weakSelf captureVideoEnded];
        };
        _finishBoard.bilateralAction = ^{//buffing skin
            if ([weakSelf.filter isKindOfClass:[GPUImageBilateralFilter class]]) {
                weakSelf.filter = nil;
                [weakSelf openFilter:NO];
            }else if ([weakSelf.filter isKindOfClass:[GPUImageBrightnessFilter class]]){
                weakSelf.filter = weakSelf.bilateralFilter;
                [weakSelf openFilter:YES];
            }else{
                weakSelf.filter = weakSelf.bilateralFilter;
                [weakSelf openFilter:YES];
            }
        };
        _finishBoard.brightnessAction = ^{//beautify skin
            if ([weakSelf.filter isKindOfClass:[GPUImageBrightnessFilter class]]) {
                weakSelf.filter = nil;
                [weakSelf openFilter:NO];
            }else if ([weakSelf.filter isKindOfClass:[GPUImageBilateralFilter class]]){
                weakSelf.filter = weakSelf.brightnessFilter;
                [weakSelf openFilter:YES];
            }else{
                weakSelf.filter = weakSelf.brightnessFilter;
                [weakSelf openFilter:YES];
            }
        };
    }
    return _finishBoard;
}


-(UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]initWithFrame:CGRectMake(23, CGRectGetMinY(_finishBoard.frame)-50, WIDTH-23*2, 50)];
//        _slider.minimumValue = 0;
//        _slider.maximumValue = 1;
        _slider.minimumTrackTintColor = [UIColor redColor];
        _slider.maximumTrackTintColor = [UIColor whiteColor];
        [_slider setThumbImage:[UIImage imageNamed:@"shoot_play_round_n"] forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(sliderChangeAction:) forControlEvents:UIControlEventValueChanged];
        _slider.value = _intensity;
    }
    return _slider;
}


-(void)setFilter:(GPUImageOutput<GPUImageInput> *)filter{
    _filter = filter;
    
    if (_filter == nil) {
        NSLog(@"滤镜为nil");
    }
    
    _slider.hidden = _filter == nil;
    
    if ([filter isKindOfClass:[GPUImageBilateralFilter class]]) {
        self.intensity = _bilateralFilter.distanceNormalizationFactor/bilateralMaxValue;
    }else if ([filter isKindOfClass:[GPUImageBrightnessFilter class]]){
        self.intensity = _brightnessFilter.brightness/beautifyMaxValue;
    }
    
}

-(void)setIntensity:(CGFloat)intensity{
    _intensity = intensity;
    _slider.value = intensity;
}


-(void)sliderChangeAction:(UISlider *)sender{
    NSLog(@"滑杆的值为：%f", sender.value);
    _intensity = sender.value;
    if ([_filter isKindOfClass:[GPUImageBilateralFilter class]]) {
        _bilateralFilter.distanceNormalizationFactor = _intensity*bilateralMaxValue;
    }else if ([_filter isKindOfClass:[GPUImageBrightnessFilter class]]){
        _brightnessFilter.brightness = _intensity*beautifyMaxValue;
    }
}


//-(JKCameraButton *)creatCaptureButton{
//    if (!_captureButton) {
//        _captureButton = [[JKCameraButton alloc]initWithFrame:CGRectMake(WIDTH/2-60/2, HEIGHT-70, 60, 60) superView:self.view];
//        _captureButton.delegate = self;
//    }
//    return _captureButton;
//}


#pragma mark - camera button delegate -
//capture photo
-(void)capturePhoto{
    
//    [_captureButton setEnabled:NO];
    self.finishBoard.enable = NO;
    [self captureFlashWithMode:_captureLightMode];
    [_photoCamera capturePhotoAsJPEGProcessedUpToFilter:_filterGroup withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        
        [self captureFlashWithMode:AVCaptureTorchModeOff];
        UIImage *image = [UIImage imageWithData:processedJPEG];
        [self.phManager saveImage:image assetCollectionName:[SystemInvestigator appName]];
        
    }];
    
}

//capture video begin
-(void)captureVideoBegan{
    // Start write data
    pathToMovie = [NSHomeDirectory()  stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    CGSize size = CGSizeZero;
    switch (_sizeType) {
        case SizeOfPictureType16x9:
            size = CGSizeMake(WIDTH, HEIGHT);
            break;
            
        case SizeOfPictureType4x3:
            size = CGSizeMake(WIDTH, WIDTH);
            break;
            
        case SizeOfPictureType1x1:
            size = CGSizeMake(480.0, 640.0);
            break;
            
        default:
            size = CGSizeMake(WIDTH, HEIGHT);
            break;
    }

    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:size];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    [_filter addTarget:_movieWriter];

    _photoCamera.audioEncodingTarget = _movieWriter;
    
    [self.movieWriter startRecording];
}


//capture video end
-(void)captureVideoEnded{
    
    //End writ data
    _photoCamera.audioEncodingTarget = nil;
    NSLog(@"Path %@",pathToMovie);
    [self.movieWriter finishRecording];
    [_filter removeTarget:_movieWriter];
    [self saveVideo];

//    [_movieWriter cancelRecording];
    
}

-(void)saveVideo{
    UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie, nil, nil, nil);
}

#pragma mark - PHManager delegate -

-(void)saveimageFinish{
    self.finishBoard.enable = NO;
    // [SVProgressHUD showSuccessWithStatus:@"保存成功"];
}

-(void)saveImageFailure{
    self.finishBoard.enable = NO;
    // [SVProgressHUD showErrorWithStatus:@"保存失败"];
}

-(void)configurationPhotoCamera{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        //无权限
        NSLog(@"此功能需您到:设置->隐私->相机里面打开权限");
        //        alert.delegate = self;
        return;
    }
    
    // 创建照片源
    // SessionPreset:屏幕分辨率，AVCaptureSessionPresetHigh会自适应高分辨率
    // cameraPosition:摄像头方向
    GPUImageStillCamera *photoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    photoCamera.outputImageOrientation = UIDeviceOrientationPortrait;
    [photoCamera setHorizontallyMirrorFrontFacingCamera:YES];
    
    _photoCamera = photoCamera;

    // 创建最终预览View
    GPUImageView *photoPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [photoPreview setBackgroundColorRed:155 green:255 blue:255 alpha:1];
    [self.view insertSubview:photoPreview atIndex:0];
    _captureVideoPreview  = photoPreview;
    
    // 设置处理链
    [_photoCamera addTarget:self.filterGroup];
    [_photoCamera addTarget:_captureVideoPreview];
    [_photoCamera addAudioInputsAndOutputs];

    // 必须调用startCameraCapture，底层才会把采集到的视频源，渲染到GPUImageView中，就能显示了。
    // 开始采集视频
    [photoCamera startCameraCapture];

}






- (void)openFilter:(BOOL)open {
    _filterGroup = nil;
    //移除之前所有处理链
    [_photoCamera removeAllTargets];
    
    // 切换美颜效果原理：移除之前所有处理链，重新设置处理链
    if (open) {
        // 设置GPUImage处理链，从数据源 => 滤镜 => 最终界面效果
        [_filter addTarget:self.filterGroup];
        [self addGPUImageFilter:_filter];
        [_filter addTarget:_captureVideoPreview];
        
    } else {
        [_photoCamera addTarget:self.filterGroup];
        [_filterGroup addTarget:_captureVideoPreview];
    }
    
}

//添加滤镜
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{

    [self.filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = _filterGroup.filterCount;
    
    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end



