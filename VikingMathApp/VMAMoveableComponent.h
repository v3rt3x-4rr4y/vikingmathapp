//
//  VMAMoveableComponent.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAComponent.h"

@interface VMAMoveableComponent : VMAComponent

-(id)initWithLocation:(CGPoint)theLocation;
-(void)updateLocation:(CGPoint)location;
-(CGPoint)getLocation;

@end
