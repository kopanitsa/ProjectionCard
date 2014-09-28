//
//  Effect1.m
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/09/28.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Effect1.h"

@implementation Effect1

-(void) setup {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(screen);
    CGFloat height = CGRectGetHeight(screen);
    self.position = ccp(width*0.5f, height*0.5f + 40);
    self.rotation = 90;
    self.visible = false;
    self.scale = 1.f;
}

-(void) show {
    self.visible = true;
}

-(void) hide {
    self.visible = false;
}

@end
