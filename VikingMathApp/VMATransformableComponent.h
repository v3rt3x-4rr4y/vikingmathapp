//
//  VMAMoveableComponent.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAComponent.h"
@class SKAction;

@interface VMATransformableComponent : VMAComponent

@property (assign) CGPoint location;

-(id)initWithLocation:(CGPoint)theLocation;

@end
