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
#import "VMADropZone.h"
#import "VMADropZoneManager.h"
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

static const NSString* DROP_ZONE_SLOT_INDEX_KEY = @"dzSlotIndex";
static const NSString* ASSIGNED_VIKINGS_KEY = @"assgdViks";

@implementation VMALongshipManager
{
    NSMutableDictionary* _longships;
    AppDelegate* _appDelegate;
    VMAGroupsActivityBuildScene* _scene;
    BOOL _actionsCompleted;
}

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene
{
    if (self = [super init])
    {
        _scene = invokingScene;
        _longships = [NSMutableDictionary dictionary];
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _actionsCompleted = YES;
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
    // TODO: check for vikings assigned to this longship and despawn them (return to the pool)

    [_longships removeObjectForKey:@(_draggedEntity.eid)];
    [[_appDelegate entityManager] removeEntity:_draggedEntity];
    //NSLog(@"Removed longship with ID: %d", _draggedEntity.eid);
    _actionsCompleted = YES;
    _dragStart = CGPointZero;
    _draggedEntity = nil;
    [_scene handleHighlights];
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

    NSMutableDictionary* value = [NSMutableDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:0], [NSArray array]]
                                                                    forKeys:@[DROP_ZONE_SLOT_INDEX_KEY, ASSIGNED_VIKINGS_KEY]];

    [_longships setObject:value forKey:@(longship.eid)];
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
    // suppress scene updates until entity animations have completed
    if (_actionsCompleted)
    {
        _draggedEntity = dragEntity;
        _dragStart = location;

        // TODO: this longship no longer occupies a drop zone slot - reset its index to -1 in _lonships

    }
}

-(void)actionCompleted
{
    _actionsCompleted = YES;
    [self printDebugInfo];
}

-(void)longshipDragStop:(CGPoint)location;
{
    _actionsCompleted = NO;
    SKAction* despawnAction = [SKAction performSelector:@selector(removeDraggedLongship) onTarget:self];
    CGRect boatShedRect = [_scene getBoatShedRect];
    CGPoint targetLocBoatShed = CGPointMake(boatShedRect.origin.x + BOATSHEDOFFSET,
                                            (boatShedRect.origin.y + (boatShedRect.size.height / 2)));
    // if drag began at a drop zone...
    __block VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByOccupiedDropZoneSlot:_dragStart];
    VMADropZone* dzUnocc = [[_scene getDropZoneManager] rectIntersectsUnoccupiedDropZoneSlot:[self longshipFrameForEntity:_draggedEntity]];
    __weak VMALongshipManager* weakSelf = self;
    if (dzOcc != nil)
    {
        // ...test for intersections with boat shed...
        if (CGRectIntersectsRect(boatShedRect, [self longshipFrameForEntity:_draggedEntity]))
        {
            [self animateLongshipFromLocation:location
                                   toLocation:targetLocBoatShed
                                   withAction:[SKAction runBlock:^
                                               {
                                                   [weakSelf removeDraggedLongship];
                                                   dzOcc.occupied = NO;
                                                   [weakSelf actionCompleted];
                                               }]];
        }

        // ... and unoccupied drop zones...
        else if (dzUnocc != nil)
        {
            CGPoint targetLocDropZone = CGPointMake(dzUnocc.rect.origin.x + (dzUnocc.rect.size.width / 2),
                                                    dzUnocc.rect.origin.y + (dzUnocc.rect.size.height / 2));
            [self animateLongshipFromLocation:location
                                   toLocation:targetLocDropZone
                                   withAction:[SKAction runBlock:^{[weakSelf actionCompleted];}]];

            dzOcc.occupied = NO;
            dzUnocc.occupied = YES;

            // Update dragged longship's drop zone slot index
            NSMutableDictionary* lsDict = [_longships objectForKey:@(_draggedEntity.eid)];
            if (lsDict)
            {
                lsDict[DROP_ZONE_SLOT_INDEX_KEY] = [NSNumber numberWithInt:dzUnocc.index];
            }

            _dragStart = CGPointZero;
            _draggedEntity = nil;
        }

        // ... otherwise animate back to drag start location
        else
        {
            [self animateLongshipFromLocation:location toLocation:_dragStart withAction:[SKAction runBlock:^{[weakSelf actionCompleted];}]];
            _dragStart = CGPointZero;
            _draggedEntity = nil;
        }
    }

    // else if dragstart location intersects the boat shed...
    else if (CGRectContainsPoint([_scene getBoatProwRect], _dragStart))
    {
        // ...test for intersections with unoccupied drop zones
        if (dzUnocc != nil)
        {
            CGPoint targetLocDropZone = CGPointMake(dzUnocc.rect.origin.x + (dzUnocc.rect.size.width / 2),
                                                    dzUnocc.rect.origin.y + (dzUnocc.rect.size.height / 2));
            dzUnocc.occupied = YES;
            [self animateLongshipFromLocation:location toLocation:targetLocDropZone withAction:[SKAction runBlock:^{[weakSelf actionCompleted];}]];

            // Update dragged longship's drop zone slot index
            NSMutableDictionary* lsDict = [_longships objectForKey:@(_draggedEntity.eid)];
            if (lsDict)
            {
                lsDict[DROP_ZONE_SLOT_INDEX_KEY] = [NSNumber numberWithInt:dzUnocc.index];
            }

            _dragStart = CGPointZero;
            _draggedEntity = nil;
        }

        // ... otherwise animate back to boat shed and despawn
        else
        {
            [self animateLongshipFromLocation:location
                                   toLocation:targetLocBoatShed
                                   withAction:despawnAction];
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

-(void)printDebugInfo
{
    for (NSObject* obj in [_longships allKeys])
    {
        unsigned int i = [(NSNumber*)obj intValue];
        NSMutableDictionary* dict = [_longships objectForKey:obj];
        NSNumber* num = dict[DROP_ZONE_SLOT_INDEX_KEY];
        NSLog(@"Longship: %d is in drop zone: %d", i, [num intValue]);
    }
    NSLog(@"----------------------------");
}

@end
