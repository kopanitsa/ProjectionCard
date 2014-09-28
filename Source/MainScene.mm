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

// #define USE_FRONT_CAMERA
#define THRESHOLD_HALLOW 0.2


@implementation MainScene {
    UIViewController* mUiViewController;
    
    Hallow* mHallowNode;
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
    mHallowNode = (Hallow*)[CCBReader load:@"Hallow"];
    [mHallowNode setup];
    [self addChild:mHallowNode];

    mEffect1Node = (Effect1*)[CCBReader load:@"Effect1"];
    [mEffect1Node setup];
    [self addChild:mEffect1Node];
    [mEffect1Node hide];
    
    mEffect2Node = (Effect2*)[CCBReader load:@"Effect2"];
    [mEffect2Node setup];
    [self addChild:mEffect2Node];
    [mEffect2Node hide];
    
    mEffect3Node = (Effect3*)[CCBReader load:@"Effect3"];
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
    
    // 画像への出力を作成
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    self.videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    
    // ビデオ出力のキャプチャの画像情報のキューを設定
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    // キャプチャーセッションに追加
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    
    // ビデオ入力のAVCaptureConnectionを取得
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
    [self detectHallow:input];
    //[self detectSomething:input];
}

-(void) hideAll {
    [mHallowNode hide];
    [mEffect1Node hide];
    [mEffect2Node hide];
    [mEffect3Node hide];
}

-(void)detectHallow:(UIImage*)image {
    NSString* match = @"hallow";
    double value = [OpenCVUtil templateMatch:image target:match];
    
    NSLog(@"value for %@ is %f", match, value);
    if (value > THRESHOLD_HALLOW) {
        if (mState == STATE_CARD_OFF) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (arc4random() % 100 < 80) {
                    NSLog(@"show effect 1!!!");
                    [mEffect1Node show];
                } else {
                    NSLog(@"show effect 2!!!");
                    [mEffect2Node show];
                }
            });
        }
        mState = STATE_CARD_ON;
    } else {
        mState = STATE_CARD_OFF;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAll];
        });
    }
}

/** template
-(void)detectSomething:(UIImage*)image {
    NSString* match = @"something";
    double value = [OpenCVUtil templateMatch:image target:match];
    
    NSLog(@"value for %@ is %f", match, value);
    if (value > THRESHOLD_SOMETHING) {
        if (mState == STATE_CARD_OFF) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // logic
            });
        }
        mState = STATE_CARD_ON;
    } else {
        mState = STATE_CARD_OFF;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAll];
        });
    }
}
*/

@end
