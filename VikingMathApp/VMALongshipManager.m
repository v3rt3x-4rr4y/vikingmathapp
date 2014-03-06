//
//  VMALongshipManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 06/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "VMALongshipManager.h"
#import "VMAEntityManager.h"
#import "VMAEntityfactory.h"
#import "VMAComponent.h"
#import "VMARenderableComponent.h"
#import "VMATransformableComponent.h"
#import "VMAAnimatableComponent.h"
#import "VMAEntity.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation VMALongshipManager
{
    NSMutableSet* _longships;
    AppDelegate* _appDelegate;
    VMAEntity* _draggedEntity;
}

-(instancetype)init
{
    if (self = [super init])
    {
        _longships = [NSMutableSet set];
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _draggedEntity = nil;
    }
    return self;
}

-(BOOL)mobileLongshipIsActive
{
    return _mobileLongship != nil;
}

-(CGRect)mobileLongshipFrame
{
    CGRect retVal = CGRectZero;
    VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                   forEntity:_mobileLongship];
    if (vrcomp)
    {
        VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
        retVal = [rcomp getSprite].frame;
    }
    return retVal;
}

-(void)removeMobileLongship
{
    [[_appDelegate entityManager] removeEntity:_mobileLongship];
    _mobileLongship = nil;
}

-(void)createMobileLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug
{
    _mobileLongship = [[_appDelegate entityFactory] createLongshipAtLocation:location
                                                                  withParent:parent
                                                                        name:MOBILEBOATNODENAMEPREFIX
                                                                       debug:debug];
}

-(void)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug
{
    VMAEntity* longship = [[_appDelegate entityFactory] createLongshipAtLocation:location
                                                                      withParent:parent
                                                                            name:@""
                                                                           debug:debug];
    [_longships addObject:longship];
}

-(void)handleLongshipMove:(CGPoint)location withEntity:(VMAEntity*)longship
{
    VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                   forEntity:longship];
    if (vtcomp)
    {
        VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
        [tcomp setLocation:location];
    }
}

-(void)longshipDragStart:(VMAEntity*)dragEntity
{
    _draggedEntity = dragEntity;
}

-(void)longshipDragStop
{
    _draggedEntity = nil;
}

-(void)handleLongshipDrag:(CGPoint)location
{
    if (_draggedEntity)
    {

        VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                       forEntity:_draggedEntity];
        if (vtcomp)
        {
            VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
            [tcomp setLocation:location];
        }
    }
}


-(BOOL)mobileLongshipHasBlockingAnimation
{
    BOOL retVal = NO;
    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMAAnimatableComponent class]
                                                                   forEntity:_mobileLongship];
    if (vacomp)
    {
        VMAAnimatableComponent* acomp = (VMAAnimatableComponent*)vacomp;
        retVal = [acomp hasBlockingAnimation];
    }
    return retVal;
}

-(void)setAction:(SKAction*)action forLongship:(VMAEntity*)longship withBlockingMode:(BOOL)blockMode
{
    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMAAnimatableComponent class]
                                                                   forEntity:longship];
    if (vacomp)
    {
        VMAAnimatableComponent* acomp = (VMAAnimatableComponent*)vacomp;
        [acomp setAction:action withBlockingMode:YES];
    }
}

-(VMAEntity*)longshipWithId:(uint32_t)entityId
{
    VMAEntity* retVal = nil;
    for (VMAEntity* entity in _longships)
    {
        if (entity.eid == entityId)
        {
            retVal = entity;
            break;
        }
    }
    return retVal;
}

@end
