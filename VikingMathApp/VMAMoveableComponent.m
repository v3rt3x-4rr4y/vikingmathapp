//
//  VMAMoveableComponent.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAMoveableComponent.h"

@implementation VMAMoveableComponent
{
    CGPoint _location;
}

- (id)initWithLocation:(CGPoint)location
{
    if ((self = [super init]))
    {
        _location = location;
    }
    return self;
}

-(void)updateLocation:(CGPoint)location
{
    _location = location;
}

-(CGPoint)getLocation
{
    return _location;
}


@end
