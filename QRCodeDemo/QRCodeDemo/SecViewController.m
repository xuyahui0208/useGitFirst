//
//  SecViewController.m
//  QRCodeDemo
//
//  Created by 徐亚辉 on 2018/2/2.
//  Copyright © 2018年 XYH. All rights reserved.
//

#import "SecViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SecViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong)AVCaptureSession * session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer * layer;
@property (nonatomic, strong)UIImageView * imageV;

@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self scanQRCode:nil];
    [self setupUI];
    [self beginAnimation];

    // Do any additional setup after loading the view.
}
//点击事件
-(void)scanQRCode:(UIButton *)sender{
    /*创建扫描二维码流程
     1.打开后置摄像头,创建数据的输入流.实时获取摄像头中的数据
     2.创建输出流,把摄像头录入的数据 输出到 屏幕上
     3.输入流 和 输出流 之间需要一个管道进行沟通
     4.实时监测输入流的数据,查看是否有二维码/条形码
     5.如果摄像数据中,有二维码/条形码 则通知我们 (代理)
     */
    
    //为了使用摄像头,需要引入 AVFoundation框架 及其 .h 文件
    //1.获取设备摄像头对象
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.从摄像头获取输入流
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        NSLog(@"input error %@",error);
        //如果出错,直接返回
        return;
    }
    
    //3.创建输出流---用于输出影像到屏幕上
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //3.1 扫描到二维码 或者 条形码的 代理,代理方法在主线程中执行
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //4.0 创建管道
    _session = [[AVCaptureSession alloc] init];
    
    //4.1 为管道添加输入流
    [_session addInput:input];
    
    //4.2 为管道添加输出流
    [_session addOutput:output];
    
    //4.3 管道质量,高品质的输出(可选) .  流畅,高清,超清,原画
    [_session setSessionPreset:AVCaptureSessionPresetHigh]; //最高质量的输出
    
    //4.4 设置扫描的数据类型 :二维码 + 条形码,扫描数据的类型必须写在添加到管道之后
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode , AVMetadataObjectTypeEAN8Code ,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode128Code];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    CGFloat x = 150/screenHeight;
//    CGFloat y = ((screenWidth-200)/2)/screenWidth;
//    CGFloat width = 200/screenHeight;
//    CGFloat height = 200/screenWidth;
    CGFloat borderWidth = screenWidth/8*6;
    
    CGFloat x = (screenHeight/2-borderWidth/2)/screenHeight;
    CGFloat y = ((screenWidth-borderWidth)/2)/screenWidth;
    CGFloat width = borderWidth/screenHeight;
    CGFloat height = borderWidth/screenWidth;

// 设置扫码框作用范围 (由于扫码时系统默认横屏关系, 导致作用框原点变为我们绘制的框的右上角,而不是左上角) 且参数为比率不是像素点
    output.rectOfInterest = CGRectMake(x, y, width, height);

    //5.把管道中的图像读取出来
    _layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    //5.1 设置layer 的大小,frame
    _layer.frame = self.view.frame; //全屏

    //5.2 设置layer 中的图片是铺满状态
    _layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //5.3 把 layer 添加到屏幕上
    [self.view.layer addSublayer:_layer];
    
    //6.0 启动管道
    [_session startRunning];

    

}


#pragma mark - OutPutDelegate
//扫描数据成功后,自动进入下方协议方法
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0) {
        //扫描到数据: 关闭管道,移除扫描的图像
        [_session stopRunning];
        [_layer removeFromSuperlayer];
        
        //把扫描到的数据拿出来
        AVMetadataMachineReadableCodeObject *obj = metadataObjects.firstObject; //取到数组中的第一个元素
        NSLog(@"扫描到的二维码 或者 条形码 是 %@",obj.stringValue);
        // 扫码成功之后 将扫码信息显示在相应的textfield 上面
        self.scanSucceed(obj.stringValue);
        
        //一般扫描完后获取网络数据,然后根据网络地址跳转到相关页面(下载页面或更多)
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}
//画几条绿色的线条 ， 就是那个绿色的方框， 正常情况下最好使用图片的
-(void)setupUI{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat borderWidth = screenWidth/8*6;

    CALayer * layerline1 = [[CALayer alloc]init];
    layerline1.backgroundColor = [UIColor greenColor].CGColor;
//    layerline1.frame = CGRectMake(self.view.center.x-100, 150, 200, 1);
    layerline1.frame = CGRectMake(self.view.center.x-borderWidth/2, (screenHeight-borderWidth)/2, borderWidth, 1);
    [_layer addSublayer:layerline1];
    
    CALayer * layerline2 = [[CALayer alloc]init];
    layerline2.backgroundColor = [UIColor greenColor].CGColor;
    layerline2.frame = CGRectMake(self.view.center.x-borderWidth/2, (screenHeight-borderWidth)/2, 1, borderWidth);
    [_layer addSublayer:layerline2];

    CALayer * layerline3 = [[CALayer alloc]init];
    layerline3.backgroundColor = [UIColor greenColor].CGColor;
    layerline3.frame = CGRectMake(self.view.center.x+borderWidth/2,(screenHeight-borderWidth)/2 , 1, borderWidth);
    [_layer addSublayer:layerline3];

    CALayer * layerline4 = [[CALayer alloc]init];
    layerline4.backgroundColor = [UIColor greenColor].CGColor;
    layerline4.frame = CGRectMake(self.view.center.x-borderWidth/2, (screenHeight + borderWidth)/2, borderWidth, 1);
    [_layer addSublayer:layerline4];
    
    UIImageView * imageV = [[UIImageView alloc]init];
    self.imageV = imageV;
    imageV.backgroundColor = [UIColor greenColor];
    imageV.frame = CGRectMake(0, 0, borderWidth/2, 2);
    imageV.center = CGPointMake(self.view.center.x, (screenHeight + borderWidth)/2);

    [_layer addSublayer:imageV.layer];

}

//开始线条动画 上下跑的那个绿线 忽略
-(void)beginAnimation{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat borderWidth = screenWidth/8*6;

    [UIView animateWithDuration:2 animations:^{
        self.imageV.layer.frame = CGRectMake(self.view.center.x-borderWidth/4, (screenHeight +borderWidth)/2, borderWidth/2, 1);
    } completion:^(BOOL finished) {
        self.imageV.layer.frame = CGRectMake(self.view.center.x-borderWidth/4, (screenHeight - borderWidth)/2, borderWidth/2, 1);
        [self beginAnimation];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
