//
//  VMAAnimatableComponent.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 05/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAComponent.h"
@class SKAction;

@interface VMAAnimatableComponent : VMAComponent

-(instancetype)initWithAction:(SKAction*)action blocksUpdates:(BOOL)blocking;
-(BOOL)hasBlockingAnimation;
-(void)setAction:(SKAction*)action withBlockingMode:(BOOL)blocking;
-(void)setAction:(SKAction*)action withBlockingMode:(BOOL)blocking forkey:(NSString*)key;
-(SKAction*)getAction;
-(NSString*)getKey;
-(void)actionsDidComplete;

@end
