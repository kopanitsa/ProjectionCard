//
//  Hallow.m
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/08/15.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Hallow.h"

@implementation Hallow

-(void) setup {
    self.position = ccp(200,200);
    self.visible = false;
    self.scale = 2.f;
}

-(void) show {
    self.visible = true;
}

-(void) hide {
    self.visible = false;
}

@end
