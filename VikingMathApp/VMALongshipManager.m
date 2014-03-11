//
//  VMALongshipManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 06/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "VMALongshipManager.h"
#import "VMAGroupsActivityBuildScene.h"
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
    VMAGroupsActivityBuildScene* _scene;
}

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene
{
    if (self = [super init])
    {
        _scene = invokingScene;
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

-(void)animateLongshipFromLocation:(CGPoint)dropPoint
                        toLocation:(CGPoint)targetPoint
                        withAction:(SKAction*)action;
{
    if ([self longshipHasBlockingAnimation:_draggedEntity])
    {
        // longship is already being animated so do nothing
        return;
    }

    // determine action velocity based on distance
    double distance = sqrt(pow((targetPoint.x - dropPoint.x), 2.0) + pow((targetPoint.y - dropPoint.y), 2.0));

    // build move and despawn actions
    SKAction* moveAction = [SKAction moveTo:targetPoint duration:distance / TRANSLATE_VELOCITY_PIXELS_PER_SEC];
    moveAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* waitAction = [SKAction waitForDuration:DESPAWN_DELAY];
    SKAction* dropAction = action ? [SKAction sequence:@[moveAction, waitAction, action]] : [SKAction sequence:@[moveAction, waitAction]];

    // animate the mobile longship to its destination and despawn
    [self setAction:dropAction forLongship:_draggedEntity withBlockingMode:YES];
}

-(BOOL)draggingLongship
{
    return _draggedEntity != nil;
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

-(void)removeDraggedLongship
{
    [_longships removeObjectForKey:@(_draggedEntity.eid)];
    [[_appDelegate entityManager] removeEntity:_draggedEntity];
    NSLog(@"Removed longship with ID: %d", _draggedEntity.eid);
    _dragStart = CGPointZero;
    _draggedEntity = nil;
}

-(VMAEntity*)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug
{
    // can only create a new longship if we've finished dragging the current longship
    if (_draggedEntity)
    {
        return nil;
    }

    VMAEntity* longship = [[_appDelegate entityFactory] createLongshipAtLocation:location
                                                                      withParent:parent
                                                                            name:@""
                                                                           debug:debug];
    [_longships setObject:[NSArray array] forKey:@(longship.eid)];
    NSLog(@"Created longship with ID: %d", longship.eid);
    return longship;
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

-(void)longshipDragStop:(CGPoint)location;
{
    SKAction* despawnAction = [SKAction performSelector:@selector(removeDraggedLongship) onTarget:self];
    SKAction* updateHiliteAction = [SKAction performSelector:@selector(handleHighlights) onTarget:_scene];
    CGRect boatShedRect = [_scene getBoatShedRect];
    CGPoint targetLocBoatShed = CGPointMake(boatShedRect.origin.x + BOATSHEDOFFSET,
                                            (boatShedRect.origin.y + (boatShedRect.size.height / 2)));

    // if dragstart location intersects the boat shed, then test for intersections with drop zones - if fail, animate back to boat shed
    // and despawn
    if (CGRectContainsPoint([_scene getBoatProwRect], _dragStart))
    {
        CGRect dropZoneRect = [_scene getDropZoneRect];
        if (CGRectIntersectsRect(dropZoneRect, [self longshipFrameForEntity:_draggedEntity]))
        {
            CGPoint targetLocDropZone = CGPointMake(dropZoneRect.origin.x + (dropZoneRect.size.width / 2),
                                                    dropZoneRect.origin.y + (dropZoneRect.size.height / 2));

            [self animateLongshipFromLocation:location toLocation:targetLocDropZone withAction:nil];
            _dragStart = CGPointZero;
            _draggedEntity = nil;
        }
        else
        {
            [self animateLongshipFromLocation:location
                                   toLocation:targetLocBoatShed
                                   withAction:[SKAction sequence:@[despawnAction, updateHiliteAction]]];
        }
    }

    // else if drag began at a drop zone, test for intersections with (a) boat shed (b) drop zone(s) - if fail, animate back to drag start
    else if (CGRectContainsPoint([_scene getDropZoneRect], _dragStart))
    {
        if (CGRectIntersectsRect(boatShedRect, [self longshipFrameForEntity:_draggedEntity]))
        {
            [self animateLongshipFromLocation:location
                                   toLocation:targetLocBoatShed
                                   withAction:[SKAction sequence:@[despawnAction, updateHiliteAction]]];
        }
        else
        {
            [self animateLongshipFromLocation:location toLocation:_dragStart withAction:nil];
            _dragStart = CGPointZero;
            _draggedEntity = nil;
        }
    }
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
