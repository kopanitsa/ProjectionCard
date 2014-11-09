//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Hallow.h"
#import "Effect1.h"
#import "Effect2.h"
#import "Effect3.h"

#define USE_FRONT_CAMERA


@implementation MainScene {
    UIViewController* mUiViewController;
    
    Effect1* mEffect1Node;
    Effect2* mEffect2Node;
    Effect3* mEffect3Node;
    
    State mState;
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
}

- (void)onEnter {
    [super onEnter];
    mUiViewController = [CCDirector sharedDirector];
    
    [OpenCVUtil surfInit];
    [self setupAVCapture];
    
    [self initHallows];
    mState = STATE_CARD_OFF;
}

- (void) onExit {
    [self teardownAVCapture];
    [super onExit];
}

- (void) initHallows {
    mEffect1Node = (Effect1*)[Effect1 create];
    [mEffect1Node setup];
    [self addChild:mEffect1Node];
    [mEffect1Node hide];
    
    mEffect2Node = (Effect2*)[Effect2 create];
    [mEffect2Node setup];
    [self addChild:mEffect2Node];
    [mEffect2Node hide];
    
    mEffect3Node = (Effect3*)[Effect3 create];
    [mEffect3Node setup];
    [self addChild:mEffect3Node];
    [mEffect3Node hide];
}

#pragma mark - Private methods

- (void)setupAVCapture
{
    self.session = [[AVCaptureSession alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
	} else {
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
	}
    
    
    AVCaptureDevice *device;
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
#ifdef USE_FRONT_CAMERA
		if ([d position] == AVCaptureDevicePositionFront) {
			device = d;
            self.isUsingFrontFacingCamera = YES;
			break;
		}
#else
		if ([d position] == AVCaptureDevicePositionBack) {
			device = d;
            self.isUsingFrontFacingCamera = YES;
			break;
		}
#endif
	}
    
    // generate input from camera
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                                  [NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
		[alertView show];
		[self teardownAVCapture];
        return;
    }
    
    // add capture session
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    
    // generate video output
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    // add video output to capture session
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    AVCaptureConnection *videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = [AVFoundationUtil videoOrientationFromDeviceOrientation:[UIDevice currentDevice].orientation];
    videoConnection.videoMinFrameDuration = CMTimeMake(1, 1);
    
    [self.session startRunning];
}

- (void)teardownAVCapture
{
	self.videoDataOutput = nil;
	if (self.videoDataOutputQueue) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		dispatch_release(self.videoDataOutputQueue);
#endif
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [AVFoundationUtil imageFromSampleBuffer:sampleBuffer];
    [self logic:image];
}

-(void)logic:(UIImage*)input {
    bool ret = false;
    ret = [self detectCard:input node:mEffect1Node];
    if (!ret){ ret = [self detectCard:input node:mEffect2Node]; }
    if (!ret){ ret = [self detectCard:input node:mEffect3Node]; }

    mState = ret ? STATE_CARD_ON : STATE_CARD_OFF;
    if (mState == STATE_CARD_OFF) {
        [self hideAll];
    }
}

-(void) hideAll {
    [mEffect1Node hide];
    [mEffect2Node hide];
    [mEffect3Node hide];
}

-(bool)detectCard:(UIImage*)image node:(EffectBase*)node{
    double value = [OpenCVUtil surfMatch:image target:node.targetImage];
    
    if (value < node.detectThresholdCard) {
        NSLog(@"detected effect %@", node.targetImage);
        if (mState == STATE_CARD_OFF) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger v = arc4random() % 100;
                if (v < node.displayPossibility) {
                    NSLog(@"show effect %@!!!", node.targetImage);
                    [node show];
                } else {
                    // do nothing
                }
            });
        }
        return true;
    }
    return false;
}

@end
