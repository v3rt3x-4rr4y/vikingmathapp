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
#import "Physics.h"

#pragma mark PRIVATE METHODS

@interface VMALongshipManager()
-(void)addVikingWithId:(uint32_t)vikingId toLongshipWithId:(uint32_t)longshipId;
-(void)removeVikingWithId:(uint32_t)vikingId;
@end

#pragma mark -

@implementation VMALongshipManager
{
    NSMutableDictionary* _longships;
    AppDelegate* _appDelegate;
}

-(instancetype)init
{
    if (self = [super init])
    {
        _longships = [NSMutableDictionary dictionary];
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

-(void)addVikingWithId:(uint32_t)vikingId toLongshipWithId:(uint32_t)longshipId
{

}

-(void)removeVikingWithId:(uint32_t)vikingId
{

}

-(BOOL)dropLongship:(VMAEntity*)longshipEntity
              rect1:(CGRect)intersectRect1
              rect2:(CGRect)intersectRect2
               drop:(CGPoint)dropPoint
             point1:(CGPoint)targetPoint1
             point2:(CGPoint)targetPoint2
         withAction:(SKAction*)action;
{
    BOOL success = NO;
    if ([self longshipHasBlockingAnimation:longshipEntity])
    {
        // longship is already being animated so do nothing
        return success;
    }

    CGPoint targetLoc = CGPointZero;
    SKAction* dropAction = nil;

    if (CGRectIntersectsRect(intersectRect1, intersectRect2))
    {
        // longship will be dropped at targetPoint1
        targetLoc = targetPoint1;
        success = YES;
    }
    else
    {
        // longship will be dropped at targetPoint2
        targetLoc = targetPoint2;
        success = NO;
    }

    // determine action velocity based on distance
    double distance = sqrt(pow((targetLoc.x - dropPoint.x), 2.0) + pow((targetLoc.y - dropPoint.y), 2.0));

    // build move and despawn actions
    SKAction* moveAction = [SKAction moveTo:targetLoc duration:distance / TRANSLATE_VELOCITY_PIXELS_PER_SEC];
    moveAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* waitAction = [SKAction waitForDuration:DESPAWN_DELAY];
    dropAction = action ? [SKAction sequence:@[moveAction, waitAction, action]] : [SKAction sequence:@[moveAction, waitAction]];

    // animate the mobile longship to its destination and despawn
    [self setAction:dropAction forLongship:longshipEntity withBlockingMode:YES];

    return success;
}

-(BOOL)mobileLongshipIsActive
{
    return _mobileLongship != nil;
}

-(CGRect)mobileLongshipFrame
{
    return [self longshipFrameForEntity:_mobileLongship];
}

-(CGRect)draggedLongshipFrame
{
    return [self longshipFrameForEntity:_draggedEntity];
}

-(CGRect)longshipFrameForEntity:(VMAEntity*)entity
{
    CGRect retVal = CGRectZero;
    VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                   forEntity:entity];
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

-(void)removeDraggedLongship
{
    [_longships removeObjectForKey:@(_draggedEntity.eid)];
    [[_appDelegate entityManager] removeEntity:_draggedEntity];
    NSLog(@"Removed longship with ID: %d", _draggedEntity.eid);
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
    [_longships setObject:[NSArray array] forKey:@(longship.eid)];
    NSLog(@"Created longship with ID: %d", longship.eid);
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

-(void)longshipDragStart:(VMAEntity*)dragEntity location:(CGPoint)location;
{
    _draggedEntity = dragEntity;
    _dragStart = location;
}

-(void)longshipDragStop
{
    _dragStart = CGPointZero;
    _draggedEntity = nil;
}

-(void)handleLongshipDrag:(CGPoint)location
{
    [self handleLongshipMove:location withEntity:_draggedEntity];
}

-(BOOL)longshipHasBlockingAnimation:(VMAEntity*)entity
{
    BOOL retVal = NO;
    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMAAnimatableComponent class]
                                                                   forEntity:entity];
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

@end
