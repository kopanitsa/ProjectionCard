//
//  OpenCVUtil.h
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/08/14.
//  Copyright (c) 2014年 Takahiro Okada. All rights reserved.
//
//  referred http://dev.classmethod.jp/smartphone/iphone/opencv-video/
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

@interface OpenCVUtil : NSObject

/**
 `UIImage`インスタンスをOpenCV画像データに変換するメソッド
 
 @param     image       `UIImage`インスタンス
 @return    `IplImage`インスタンス
 */
+ (IplImage *)IplImageFromUIImage:(UIImage *)image;

/**
 OpenCV画像データを`UIImage`インスタンスに変換するメソッド
 
 @param     image `IplImage`インスタンス
 @return    `UIImage`インスタンス
 */
+ (UIImage *)UIImageFromIplImage:(IplImage*)image;

+ (bool)detect:(UIImage *)srcImage cascade:(NSString *)cascadeFilename; // cascade matching
+ (double)shapeMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename;  // template matching
+ (double)templateMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename;  // template matching

+ (void)surfInit;
+ (double)surfMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename;


@end