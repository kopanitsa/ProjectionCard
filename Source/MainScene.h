//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "AVFoundationUtil.h"
#import "OpenCVUtil.h"


@interface MainScene : CCNode<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (assign, nonatomic) BOOL isUsingFrontFacingCamera;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (strong, nonatomic) CALayer *previewLayer;

typedef enum : NSInteger {
    STATE_CARD_ON = 1,
    STATE_CARD_OFF,
    STATE_CARD_CHANGED,
    
} State;

@end
