//
//  XHQRCoderProduct.m
//  MADPMainRootMenu
//
//  Created by 徐亚辉 on 2018/1/12.
//  Copyright © 2018年 XYH. All rights reserved.
//

#import "XHQRCoderProduct.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
@implementation XHQRCoderProduct
#pragma mark 二维码初始化的4个方法
//生成普通的二维码图片 默认宽度100.f
+ (UIImage *)imageOfQRFromURL:(NSString *)networkAddress{
    return [self imageOfQRFromURL: networkAddress codeSize: 100.0f red: 0 green: 0 blue: 0 insertImage: nil roundRadius: 0.f];
    
}
//生成普通的有尺寸的二维码
+ (UIImage *)imageOfQRFromURL: (NSString *)networkAddress codeSize: (CGFloat)codeSize{
    if (!networkAddress|| (NSNull *)networkAddress == [NSNull null])
    {
        return nil;
    }
    codeSize = [self validateCodeSize: codeSize];
    CIImage * originImage = [self createQRFromAddress: networkAddress];
    //这个图片清晰度会有问题
//            UIImage * result = [UIImage imageWithCIImage: originImage];
    UIImage * result =[self excludeFuzzyImageFromCIImage: originImage size: codeSize];
    return result;
}
// 设置二维码的目标颜色和尺寸
+ (UIImage *)imageOfQRFromURL: (NSString *)networkAddress codeSize: (CGFloat)codeSize red: (NSUInteger)red green: (NSUInteger)green blue:(NSUInteger)blue{
    if (!networkAddress || (NSNull *)networkAddress == [NSNull null]) { return nil; }
    /** 颜色不可以太接近白色*/
    NSUInteger rgb = (red << 16) + (green << 8) + blue;
    NSAssert((rgb & 0xffffff00) <= 0xd0d0d000, @"The color of QR code is two close to white color than it will diffculty to scan");
    codeSize = [self validateCodeSize: codeSize];
    CIImage * originImage = [self createQRFromAddress: networkAddress];
    UIImage * progressImage = [self excludeFuzzyImageFromCIImage: originImage size: codeSize];
    //到了这里二维码已经可以进行扫描了
    UIImage * effectiveImage = [self imageFillBlackColorAndTransparent: progressImage red: red green: green blue: blue];
    //进行颜色渲染后的二维码
//    return [self imageInsertedImage: effectiveImage insertImage: insertImage radius: roundRadius];
    
    
        return effectiveImage;
}
//设置二维码的图片 的颜色 尺寸 和中间插入图片
+ (UIImage *)imageOfQRFromURL: (NSString *)networkAddress codeSize: (CGFloat)codeSize red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue insertImage: (UIImage *)insertImage roundRadius: (CGFloat)roundRadius{
    if (!networkAddress || (NSNull *)networkAddress == [NSNull null]) { return nil; }
    /** 颜色不可以太接近白色*/
    NSUInteger rgb = (red << 16) + (green << 8) + blue;
    NSAssert((rgb & 0xffffff00) <= 0xd0d0d000, @"The color of QR code is two close to white color than it will diffculty to scan");
    codeSize = [self validateCodeSize: codeSize];
    CIImage * originImage = [self createQRFromAddress: networkAddress];
    UIImage * progressImage = [self excludeFuzzyImageFromCIImage: originImage size: codeSize];
    //到了这里二维码已经可以进行扫描了
    UIImage * effectiveImage = [self imageFillBlackColorAndTransparent: progressImage red: red green: green blue: blue];
    //进行颜色渲染后的二维码
    return [self imageInsertedImage: effectiveImage insertImage: insertImage radius: roundRadius];
}









#pragma mark
/*! 验证二维码尺寸合法性*/
+ (CGFloat)validateCodeSize: (CGFloat)codeSize
{   codeSize = MAX(240, codeSize);
    codeSize = MIN(CGRectGetWidth([UIScreen mainScreen].bounds) - 80, codeSize);
    return codeSize;
}
/*! 利用系统滤镜生成二维码图*/
+ (CIImage *)createQRFromAddress: (NSString *)networkAddress{
    NSData * stringData = [networkAddress dataUsingEncoding: NSUTF8StringEncoding];
    CIFilter * qrFilter = [CIFilter filterWithName: @"CIQRCodeGenerator"];
    [qrFilter setValue: stringData forKey: @"inputMessage"];
    [qrFilter setValue: @"H" forKey: @"inputCorrectionLevel"];
    return qrFilter.outputImage;
}
//将CIImage---> 转为CGImageRef ---> 转为UIImage 类型，跳过中间的步骤会导致图片不清晰
+ (UIImage *)excludeFuzzyImageFromCIImage: (CIImage *)image size: (CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    //创建灰度色调空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext * context = [CIContext contextWithOptions: nil];
    CGImageRef bitmapImage = [context createCGImage: image fromRect: extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage: scaledImage];
}


#pragma mark 对二维码进行颜色填充
/*! 对生成二维码图像进行颜色填充*/
+(UIImage *)imageFillBlackColorAndTransparent:(UIImage *)image red:(NSUInteger)red green:(NSUInteger) green blue:(NSUInteger)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t * rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, (CGRect){(CGPointZero), (image.size)}, image.CGImage);
    //遍历像素
    int pixelNumber = imageHeight * imageWidth;
    [self fillWhiteToTransparentOnPixel: rgbImageBuf pixelNum: pixelNumber red: red green: green blue: blue];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    UIImage * resultImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return resultImage;
}
+ (void)fillWhiteToTransparentOnPixel: (uint32_t *)rgbImageBuf pixelNum: (int)pixelNum red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue{
    uint32_t * pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xffffff00) < 0xd0d0d000) {
            uint8_t * ptr = (uint8_t *)pCurPtr;
            ptr[3] = red;
            ptr[2] = green;
            ptr[1] = blue;
            
            }else {
                //将白色变成透明色
                uint8_t * ptr = (uint8_t *)pCurPtr;
                ptr[0] = 0;
            }
    }
}
void ProviderReleaseData(void * info, const void * data, size_t size) {
    free((void *)data);
}

#pragma mark 在二维码中间插入图片
/*! 在二维码原图中心位置插入圆角图像*/
//
+ (UIImage *)imageInsertedImage: (UIImage *)originImage insertImage: (UIImage *)insertImage radius: (CGFloat)radius {
    if (!insertImage) { return originImage; }
    insertImage = [self scaleImage:insertImage ToSize:CGSizeMake(80, 80)];
    insertImage = [self imageOfRoundRectWithImage: insertImage size: insertImage.size radius: radius];
//    UIImage * whiteBG = [UIImage imageNamed: @"whiteBG"];
//    UIImage * whiteBG = IMAGE(@"whiteBG");
    UIImage * whiteBG = [UIImage new];
    whiteBG = [self scaleImage:whiteBG ToSize:CGSizeMake(100, 100)];
    whiteBG = [self imageOfRoundRectWithImage: whiteBG size: whiteBG.size radius: radius];
    //白色边缘宽度
    const CGFloat whiteSize = 4.f;
    CGSize brinkSize = CGSizeMake(originImage.size.width / 4, originImage.size.height / 4);
    CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
    CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;
    CGSize imageSize = CGSizeMake(brinkSize.width - 2 * whiteSize, brinkSize.height - 2 * whiteSize);
    CGFloat imageX = brinkX + whiteSize;
    CGFloat imageY = brinkY + whiteSize;
//    UIGraphicsBeginImageContext(originImage.size);
    UIGraphicsBeginImageContextWithOptions(originImage.size, NO,4.0);

    [originImage drawInRect: (CGRect){ 0, 0, (originImage.size) }];
    [whiteBG drawInRect: (CGRect){ brinkX, brinkY, (brinkSize) }];
    [insertImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
//裁剪图片
+ (UIImage *)imageOfRoundRectWithImage: (UIImage *)image size: (CGSize)size radius: (CGFloat)radius
{
    if (!image || (NSNull *)image == [NSNull null]) { return nil; }
    
    const CGFloat width = size.width;
    const CGFloat height = size.height;
    
    radius = MAX(5.f, radius);
    radius = MIN(10.f, radius);
    
    UIImage * img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //绘制圆角
    CGContextBeginPath(context);
    addRoundRectToPath(context, rect, radius, img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage: imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return img;
}
//裁剪图片
void addRoundRectToPath(CGContextRef context, CGRect rect, float radius, CGImageRef image)
{
    float width, height;
    if (radius == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    width = CGRectGetWidth(rect);
    height = CGRectGetHeight(rect);
    
    //裁剪路径
    CGContextMoveToPoint(context, width, height / 2);
    CGContextAddArcToPoint(context, width, height, width / 2, height, radius);
    CGContextAddArcToPoint(context, 0, height, 0, height / 2, radius);
    CGContextAddArcToPoint(context, 0, 0, width / 2, 0, radius);
    CGContextAddArcToPoint(context, width, 0, width, height / 2, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRestoreGState(context);
}

+ (UIImage *)scaleImage:(UIImage *)originImage ToSize:(CGSize)size {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [originImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}


@end
