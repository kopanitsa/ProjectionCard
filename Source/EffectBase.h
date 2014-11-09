//
//  EffectBase.h
//  ProjectionCard
//
//  Created by Takahiro Okada on 2014/11/09.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface EffectBase : CCNode

@property(nonatomic) NSString* targetImage;
@property(nonatomic) float detectThresholdCard;
@property(nonatomic) int displayPossibility;

+(EffectBase*)create;
-(void) setup;
-(void) show;
-(void) hide;

@end
