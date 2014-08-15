//
//  AVFoundationUtil.h
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/08/14.
//  Copyright (c) 2014年 Takahiro Okada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

@interface AVFoundationUtil : NSObject

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

@end
