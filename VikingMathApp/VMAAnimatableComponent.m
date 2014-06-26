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
    NSString* _key;
    BOOL _isBlocking;
}

-(instancetype)initWithAction:(SKAction*)action blocksUpdates:(BOOL)blocking;
{
    if ((self = [super init]))
    {
        _currentAction = action;
        _isBlocking = blocking;
        _key = nil;
    }
    return self;
}

-(BOOL)hasBlockingAnimation
{
    return _isBlocking;
}

-(void)setAction:(SKAction*)action withBlockingMode:(BOOL)blocking
{
    _currentAction = action;
    _isBlocking = blocking;
}

-(void)setAction:(SKAction*)action withBlockingMode:(BOOL)blocking forkey:(NSString *)key
{
    _currentAction = action;
    _isBlocking = blocking;
    _key = key;
}

-(NSString*)getKey
{
    return _key;
}

-(SKAction*)getAction
{
    return _currentAction;
}

-(void)actionsDidComplete
{
    _currentAction = nil;
    _isBlocking = NO;
}

-(void)tearDown
{

}

@end
