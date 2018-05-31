//
//  ViewController.m
//  QRCodeDemo
//
//  Created by 徐亚辉 on 2018/2/2.
//  Copyright © 2018年 XYH. All rights reserved.
//
#import "ViewController.h"
#import <Masonry.h>
#import "XHQRCoderProduct.h"
#import "SecViewController.h"
#import <AFNetworking.h>
@interface ViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>{
}
@property (nonatomic,weak)UITextField * inputTextField;

@end

@implementation ViewController
static NSString * messageCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)setupUI{
    UIButton * btn1 = [self buttonWithTitle:@"生成二维码"];
    [btn1 addTarget:self action:@selector(QRCodeProduce:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    UIButton * btn2 = [self buttonWithTitle:@"扫描二维码"];
    [btn2 addTarget:self action:@selector(ScanQRCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UITextField * inputTextField = [self getTextFieldWithPlaceHolder:@"请输入要生成的二维码信息的内容"];
    inputTextField.tag  = 101;
    self.inputTextField = inputTextField;
    [self.view addSubview:inputTextField];
    
    UITextField * outputTextField = [self getTextFieldWithPlaceHolder:@"获取的二维码信息为："];
    outputTextField.tag  = 102;
    outputTextField.minimumFontSize = 8.f;
//    outputTextField.font = [UIFont systemFontOfSize:8];
    outputTextField.userInteractionEnabled = NO;
    [self.view addSubview:outputTextField];
    
    UIImageView * imageV = [[UIImageView alloc] init];
    imageV.tag = 103;
    imageV.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageV];
    
//    UIButton * btn3 = [self buttonWithTitle:@"发送网络请求"];
    UIButton * btn3 = [self buttonWithTitle:@"打开二维码网址链接"];
    [btn3 addTarget:self action:@selector(sendNet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];

    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(80);
        make.left.offset(20);
        make.height.mas_equalTo(40);
        
    }];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn1);
        make.right.offset(-20);
        make.left.equalTo(btn1.mas_right).offset(20);
        make.height.equalTo(btn1);
        make.width.equalTo(btn1);
    }];
    
    [inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btn1.mas_bottom).offset(20);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(40);
    }];
    
    [outputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputTextField.mas_bottom).offset(20);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(40);
    }];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(outputTextField.mas_bottom).offset(20);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(150);
        make.centerX.equalTo(self.view);

    }];
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-100);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(btn3.superview);
    }];
    
    
}
-(UIButton *)buttonWithTitle:(NSString *)title{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}
-(UITextField *)getTextFieldWithPlaceHolder:(NSString *)placeholder{
    UITextField * textField = [[UITextField alloc]init];
    textField.backgroundColor = [UIColor lightGrayColor];
    textField.placeholder = placeholder;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.delegate = self;
    return textField;
}
// 生成二维码
-(void)QRCodeProduce:(id)sender{
    NSString * str = self.inputTextField.text;
    UIImageView * imageV = [self.view viewWithTag:103];
    
    if (str && ![str isEqualToString:@""]) {
/*
// 这个类XHQRCoderProduct 也可以生成二维码图片
 UIImage * image = [XHQRCoderProduct imageOfQRFromURL:str];
 */
        // 生成的二维码图片
        UIImage * image = [self createQRFromAddress:str];
        imageV.image = image;
        
    }else{
        [[[UIAlertView alloc] initWithTitle:@"warning" message:@"please input the right message" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil] show];
    }
}
// 跳转扫码控制器
-(void)ScanQRCode:(id)sender{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"选择扫码方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机" ,@"相册", nil];
    [sheet showInView:self.view];
    
}
-(void)sendNet:(id)sender{
    
    NSString * urlStr = messageCode;
    if (messageCode) {
        NSURL * url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];

    }
    
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
//// get 请求
//    [manager GET:@"https://baidu.com" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
    
/* POST 请求
    NSDictionary * dic = @{
                           @"BankId" : @"9999",
                           @"_ChannelId" : @"PMBS",
                           @"_locale" : @"zh_CN"
                           };

    [manager POST:@"https://sina.com/login.do" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
 */
    
}


- (UIImage *)createQRFromAddress: (NSString *)networkAddress{
    NSData * stringData = [networkAddress dataUsingEncoding: NSUTF8StringEncoding];
    //下面3行不要动了
    CIFilter * qrFilter = [CIFilter filterWithName: @"CIQRCodeGenerator"];
    [qrFilter setValue: stringData forKey: @"inputMessage"];
    [qrFilter setValue: @"H" forKey: @"inputCorrectionLevel"];
    // 直接ciimage 转为  uiimage 会导致图片不清晰         qrFilter.outputImage的类型就是ciimage
//    return [UIImage imageWithCIImage:qrFilter.outputImage];
    //
    return [self excludeFuzzyImageFromCIImage:qrFilter.outputImage size:200];
    
    
}
//处理生成的图片的清晰度问题，其实就是重新绘制图片   这个方法写的我也不太懂，所以不要问这个了
//将CIImage---> 转为CGImageRef ---> 转为UIImage 类型，跳过中间的步骤会导致图片不清晰
-(UIImage *)excludeFuzzyImageFromCIImage: (CIImage *)image size: (CGFloat)size{

    CGRect extent = CGRectIntegral(image.extent);
    
    //设置比例
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap（位图）;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}
#pragma mark actionsheetDelegate 选择从相机还是相册选择
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex == 0) {
        // 用相机扫码
        
        SecViewController * secVC = [[SecViewController alloc]init];
        secVC.scanSucceed = ^(NSString * codeMessage) {
            // 扫码成功之后 将扫码信息显示在相应的textfield 上面
            UITextField * textField = [self.view viewWithTag:102];
            textField.text = [NSString stringWithFormat:@"二维码信息为：%@",codeMessage];
            messageCode = codeMessage;
            
        };
        [self.navigationController pushViewController:secVC animated:YES];
        return  ;
    }
    if (buttonIndex == 1) {
        // 从相册 选择
        UIImagePickerController * vc = [[UIImagePickerController alloc] init];
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        vc.delegate = self;
        [self.navigationController  presentViewController:vc animated:YES completion:nil];
    }
}
// 从相册选择二维码
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@",info);
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self SacnWithImage:image];

    }];
}
// 将二维码图片解析
-(void)SacnWithImage:(UIImage *)newImage{
    //设置 探测器 识别特征为二维码
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //
    NSData*imageData =UIImagePNGRepresentation(newImage);
    CIImage*ciImage = [CIImage imageWithData:imageData];
    // 获取图片特征
    NSArray*features = [detector featuresInImage:ciImage];
    CIQRCodeFeature*feature = [features objectAtIndex:0];
    // 二维码信息
    NSString*scannedResult = feature.messageString;
    [[[UIAlertView alloc] initWithTitle:@"二维码信息" message:scannedResult delegate:self cancelButtonTitle:@"sure" otherButtonTitles:nil, nil] show];
    
    messageCode = scannedResult;
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    return  YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
