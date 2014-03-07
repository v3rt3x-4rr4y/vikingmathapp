//
//  VMAAnimatableComponent.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 05/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAAnimatableComponent.h"

@implementation VMAAnimatableComponent
{
    SKAction* _currentAction;
    BOOL _isBlocking;
}

-(instancetype)initWithAction:(SKAction*)action blocksUpdates:(BOOL)blocking;
{
    if ((self = [super init]))
    {
        _currentAction = action;
        _isBlocking = blocking;
    }
    return self;
}

-(BOOL)hasBlockingAnimation
{
    return _isBlocking;
}

-(void)setAction:(SKAction*)action withBlockingMode:(BOOL)blocking;
{
    _currentAction = action;
    _isBlocking = blocking;
}

-(SKAction*)getAction
{
    return _currentAction;
}

-(void)actionsDidComplete
{
    _currentAction = nil;
    _isBlocking = NO;
    //NSLog(@"Action completed");
}

-(void)tearDown
{
    
}

@end
