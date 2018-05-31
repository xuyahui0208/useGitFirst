//
//  SecViewController.h
//  QRCodeDemo
//
//  Created by 徐亚辉 on 2018/2/2.
//  Copyright © 2018年 XYH. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ScanSucceed)(NSString * codeMessage);

@interface SecViewController : UIViewController
@property (nonatomic, copy)ScanSucceed scanSucceed;
@end
