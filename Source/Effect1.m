//
//  Effect1.m
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/09/28.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Effect1.h"

@implementation Effect1

+(EffectBase*)create {
    return (Effect1*)[CCBReader load:@"Effect1"];
}

-(void) setup {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(screen);
    CGFloat height = CGRectGetHeight(screen);
    self.position = ccp(width*0.8f, height*0.3f);
    self.rotation = 90;
    self.visible = false;
    self.scale = 1.f;
    
    self.targetImage = @"hallow";
    self.detectThresholdCard = 0.2f;
    self.displayPossibility = 100;

}

-(void) show {
    self.visible = true;
}

-(void) hide {
    self.visible = false;
}

@end
