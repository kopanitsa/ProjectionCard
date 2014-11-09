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

+ (IplImage *)IplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage*)image;

//+ (bool)detect:(UIImage *)srcImage cascade:(NSString *)cascadeFilename; // cascade matching
//+ (double)shapeMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename;  // template matching
+ (double)templateMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename;  // template matching

+ (void)surfInit;
+ (double)surfMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename;


@end