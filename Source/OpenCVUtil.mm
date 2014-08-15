//
//  OpenCVUtil.m
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/08/14.
//  Copyright (c) 2014年 Takahiro Okada. All rights reserved.
//

#import "OpenCVUtil.h"
#include <opencv2/nonfree/nonfree.hpp>

@implementation OpenCVUtil

+ (IplImage *)IplImageFromUIImage:(UIImage *)image
{
    CGImageRef imageRef = image.CGImage;
    
    // RGB色空間を作成
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 一時的なIplImageを作成
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4);
    
    // CGBitmapContextをIplImageのビットマップデータのポインタから作成
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData,
                                                    iplimage->width,
                                                    iplimage->height,
                                                    iplimage->depth,
                                                    iplimage->widthStep,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    // CGImageをCGBitmapContextに描画
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    
    // ビットマップコンテキストと色空間を解放
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // 最終的なIplImageを作成
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    
    // 一時的なIplImageを解放
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

+ (UIImage *)UIImageFromIplImage:(IplImage*)image
{
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        //BGRになっているのでRGBに変換
//        cvCvtColor(image, image, CV_BGR2RGB);
    }
    
    // IplImageのビットマップデータのポインタアドレスからNSDataを作成
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // CGImageを作成
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    // UIImageを生成
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

+ (bool)detect:(UIImage *)srcImage cascade:(NSString *)cascadeFilename {
    
    cv::Mat srcMat = [OpenCVUtil IplImageFromUIImage:srcImage];
    
    // グレースケール画像に変換
    cv::Mat grayMat;
    cv::cvtColor(srcMat, grayMat, CV_BGR2GRAY);
    
    // 分類器の読み込み
    NSString *path = [[NSBundle mainBundle] pathForResource:cascadeFilename
                                                     ofType:nil];
    std::string cascade_path = (char *)[path UTF8String];
    cv::CascadeClassifier cascade;
    
    if (!cascade.load(cascade_path)) {
        
        NSLog(@"Couldn't load haar cascade file.");
        return nil;
    }
    
    // 探索
    std::vector<cv::Rect> objects;
    cascade.detectMultiScale(grayMat, objects,      // 画像，出力矩形
                             1.1, 1,                // 縮小スケール，最低矩形数
                             CV_HAAR_SCALE_IMAGE,   // （フラグ）
                             cv::Size(40, 40));     // 最小矩形
    
    // 結果の描画
    std::vector<cv::Rect>::const_iterator r = objects.begin();
    for(; r != objects.end(); ++r) {
        return true;
//        cv::Point center;
//        int radius;
//        center.x = cv::saturate_cast<int>((r->x + r->width*0.5));
//        center.y = cv::saturate_cast<int>((r->y + r->height*0.5));
//        NSLog(@"%d, %d", center.x, center.y);
//        radius = cv::saturate_cast<int>((r->width + r->height)*0.25);
//        cv::circle(srcMat, center, radius, cv::Scalar(80,80,255), 3, 8, 0 );
    }
    
    return false;
}

+ (double)shapeMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename {
    // source image
    IplImage *srcImage = cvCreateImage(cvSize(srcUIImage.size.width, srcUIImage.size.height), IPL_DEPTH_8U, 4);
    IplImage *srcGray = cvCreateImage( cvGetSize(srcImage),IPL_DEPTH_8U,1);
	cvCvtColor(srcImage, srcGray, CV_BGR2GRAY);
    
    // target image
    UIImage *targetUIimage = [UIImage imageNamed:targetFilename];
    IplImage *targetImage = cvCreateImage(cvSize(targetUIimage.size.width, targetUIimage.size.height), IPL_DEPTH_8U, 4);
    IplImage *targetGray = cvCreateImage( cvGetSize(targetImage),IPL_DEPTH_8U,1);
	cvCvtColor(targetImage, targetGray, CV_BGR2GRAY);
    
    double result[3];
    result[0] = cvMatchShapes (srcGray, srcGray, CV_CONTOURS_MATCH_I1, 0);
    result[1] = cvMatchShapes (srcGray, targetGray, CV_CONTOURS_MATCH_I2, 0);
    result[2] = cvMatchShapes (srcGray, targetGray, CV_CONTOURS_MATCH_I3, 0);
    
    for (int i = 0; i < 3; i++) {
        NSLog(@"result[%d] : %f", i, result[i]);
    }
    
    cvReleaseImage (&srcImage);
    cvReleaseImage (&targetImage);
    cvReleaseImage (&srcGray);
    cvReleaseImage (&targetGray);

    return result[0];
}


+ (double)templateMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename {
    // source image
    IplImage *srcImage = [self IplImageFromUIImage:srcUIImage];
    cv::Mat img_1 = cv::cvarrToMat(srcImage);
    
    // template image
    UIImage *templateUIimage = [UIImage imageNamed:targetFilename];
    IplImage *templateImage = [self IplImageFromUIImage:templateUIimage];
    cv::Mat img_2 = cv::cvarrToMat(templateImage);
    
    // dst image
    CvSize dst_size;
    IplImage *dstImage;
    dst_size = cvSize (srcImage->width - templateImage->width + 1, srcImage->height - templateImage->height + 1);
    dstImage = cvCreateImage (dst_size, IPL_DEPTH_32F, 1);

    // matching
    double min_val, max_val;
    CvPoint min_loc, max_loc;
    cvMatchTemplate (srcImage, templateImage, dstImage, CV_TM_CCOEFF_NORMED);
    cvMinMaxLoc (dstImage, &min_val, &max_val, &min_loc, &max_loc, NULL);
    
    
    cvReleaseImage (&srcImage);
    cvReleaseImage (&templateImage);
    cvReleaseImage (&dstImage);
    return max_val;
}



+ (void)surfInit {
    cv::initModule_nonfree();
}

+ (double)surfMatch:(UIImage*)srcUIImage target:(NSString*)targetFilename {
    // source image
    IplImage *srcImage = [self IplImageFromUIImage:srcUIImage];
    cv::Mat img_1 = cv::cvarrToMat(srcImage);
    
    // template image
    UIImage *templateUIimage = [UIImage imageNamed:targetFilename];
    IplImage *templateImage = [self IplImageFromUIImage:templateUIimage];
    cv::Mat img_2 = cv::cvarrToMat(templateImage);
	   
    //-- Step 1: Detect the keypoints using SURF Detector
    int minHessian = 100;
    
    cv::SurfFeatureDetector detector( minHessian );
    
    std::vector<cv::KeyPoint> keypoints_1, keypoints_2;
    
    detector.detect( img_1, keypoints_1 );
    detector.detect( img_2, keypoints_2 );
    
    //-- Step 2: Calculate descriptors (feature vectors)
    cv::SurfDescriptorExtractor extractor;
    cv::Mat descriptors_1, descriptors_2;
    
    extractor.compute( img_1, keypoints_1, descriptors_1 );
    extractor.compute( img_2, keypoints_2, descriptors_2 );
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    cv::FlannBasedMatcher matcher;
    std::vector< cv::DMatch > matches;
    matcher.match( descriptors_1, descriptors_2, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_1.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 2*min_dist )
    //-- PS.- radiusMatch can also be used here.
    std::vector< cv::DMatch > good_matches;
    
    for( int i = 0; i < descriptors_1.rows; i++ )
    { if( matches[i].distance <= 2*min_dist )
    { good_matches.push_back( matches[i]); }
    }
    
    
    //return nil;
    return good_matches.size();
}


@end