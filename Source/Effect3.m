//
//  Effect3.m
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/09/28.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Effect3.h"

@implementation Effect3

+(EffectBase*)create {
    return (Effect3*)[CCBReader load:@"Effect3"];
}

-(void) setup {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(screen);
    CGFloat height = CGRectGetHeight(screen);
    self.position = ccp(width*0.8f, height*0.3f);
    self.rotation = 90;
    self.visible = false;
    self.scale = 1.f;
    
    self.targetImage = @"bat";
    self.detectThresholdCard = 0.37f;
    self.displayPossibility = 100;
}

-(void) show {
    self.visible = true;
}

-(void) hide {
    self.visible = false;
}


@end
