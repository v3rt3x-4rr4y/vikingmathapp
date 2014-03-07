//
//  VMAMoveableComponent.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMATransformableComponent.h"

@implementation VMATransformableComponent

- (id)initWithLocation:(CGPoint)location
{
    if ((self = [super init]))
    {
        _location = location;
    }
    return self;
}


-(void)tearDown
{

}

@end
