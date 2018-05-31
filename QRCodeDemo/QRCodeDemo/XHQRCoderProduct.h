//
//  XHQRCoderProduct.h
//  MADPMainRootMenu
//
//  Created by 徐亚辉 on 2018/1/12.
//  Copyright © 2018年 XYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface XHQRCoderProduct : NSObject
/**
 @param networkAddress  需要跳转的地址
 @param codeSize  size 尺寸
 @return 二维码图片
 */

+ (UIImage *)imageOfQRFromURL: (NSString *)networkAddress codeSize: (CGFloat)codeSize;
/**
 生成 默认 宽高100 的二维码图片
 @param networkAddress  需要跳转的地址
 @return 二维码图片
 */
+ (UIImage *)imageOfQRFromURL:(NSString *)networkAddress;

/**
 设置二维码的  地址 尺寸 颜色
 @param networkAddress 地址
 @param codeSize 尺寸
 @param red 颜色
 @param green 颜色
 @param blue 颜色
 @return 二维码图片
 */
+ (UIImage *)imageOfQRFromURL: (NSString *)networkAddress codeSize: (CGFloat)codeSize red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue;

/**
 设置二维码的 地址 尺寸 颜色  中间插入的图片
 @param networkAddress 地址
 @param codeSize 尺寸
 @param red 颜色
 @param green 颜色
 @param blue 颜色
 @param insertImage 插入图片
 @param roundRadius 弧度
 @return 二维码图片
 */
+ (UIImage *)imageOfQRFromURL: (NSString *)networkAddress codeSize: (CGFloat)codeSize red: (NSUInteger)red green: (NSUInteger)green blue: (NSUInteger)blue insertImage: (UIImage *)insertImage roundRadius: (CGFloat)roundRadius;
@end
