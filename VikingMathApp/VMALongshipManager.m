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

@end

#pragma mark -

static const NSString* DROP_ZONE_SLOT_INDEX_KEY = @"dzSlotIndex";
static const NSString* NUM_ASSIGNED_VIKINGS_KEY = @"assgdViks";

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

-(NSMutableDictionary*)dataForLongshipInDropZone:(int)dropzoneIndex
{
    NSMutableDictionary* retVal = nil;
    for (NSObject* obj in [_longships allKeys])
    {
        NSMutableDictionary* dict = [_longships objectForKey:obj];
        if ([(NSNumber*)dict[DROP_ZONE_SLOT_INDEX_KEY] intValue] == dropzoneIndex)
        {
            retVal = dict;
            break;
        }
    }
    return retVal;
}

-(int)numVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
{
    int retVal = -1;
    NSMutableDictionary* lsDict = [self dataForLongshipInDropZone:dropZoneId];
    if (lsDict)
    {
        retVal = [(NSNumber*)[lsDict objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue];
    }
    return retVal;
}

-(int)numVikingsOnboardForLongshipWithId:(uint32_t)longshipId
{
    int retVal = -1;
    NSMutableDictionary* dict = [_longships objectForKey:@(longshipId)];
    if (dict)
    {
        retVal = [(NSNumber*)dict[NUM_ASSIGNED_VIKINGS_KEY] intValue];
    }
    return retVal;
}

-(void)incrementVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
{
    NSMutableDictionary* lsDict =  [self dataForLongshipInDropZone:dropZoneId];
    if (lsDict)
    {
        int val = 1 + [(NSNumber*)[lsDict objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue];
        lsDict[NUM_ASSIGNED_VIKINGS_KEY] = [NSNumber numberWithInt:val];
        NSLog(@"Longship in drop zone: %d now has: %d vikings on board", dropZoneId, val);
    }
}

-(void)decrementVikingsOnboardForLongshipInDropZone:(int)dropZoneId;

{
    NSMutableDictionary* lsDict =  [self dataForLongshipInDropZone:dropZoneId];
    if (lsDict)
    {
        int val = [(NSNumber*)[lsDict objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue] - 1;
        lsDict[NUM_ASSIGNED_VIKINGS_KEY] = [NSNumber numberWithInt:val];
        NSLog(@"Longship in drop zone: %d now has: %d vikings on board", dropZoneId, val);
    }
}

-(void)animateDraggedActorFromLocation:(CGPoint)dropPoint
                            toLocation:(CGPoint)targetPoint
                            withAction:(SKAction*)action;
{
    if ([self actorHasBlockingAnimation:_draggedEntity])
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
    [self setAction:dropAction forActor:_draggedEntity withBlockingMode:YES];
}

-(BOOL)draggingActor
{
    return _draggedEntity != nil;
}

-(CGRect)draggedActorFrame
{
    return [self actorFrameForEntity:_draggedEntity];
}

-(CGRect)actorFrameForEntity:(VMAEntity*)entity
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

-(void)removeDraggedActor
{
    [_longships removeObjectForKey:@(_draggedEntity.eid)];
    [[_appDelegate entityManager] removeEntity:_draggedEntity];
    NSLog(@"Removed longship with ID: %d", _draggedEntity.eid);
    _actionsCompleted = YES;
    _dragStart = CGPointZero;
    _draggedEntity = nil;
    [_scene handleHighlights];
}

-(VMAEntity*)createActorAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug
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

    NSMutableDictionary* value = [NSMutableDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:0], [NSNumber numberWithInt:0]]
                                                                    forKeys:@[DROP_ZONE_SLOT_INDEX_KEY, NUM_ASSIGNED_VIKINGS_KEY]];

    [_longships setObject:value forKey:@(longship.eid)];

    //DEBUG ONLY:
    //[self incrementVikingsOnboardForlongship:longship.eid];

    return longship;
}

-(void)handleActorMove:(CGPoint)location withEntity:(VMAEntity*)actor
{
    VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                   forEntity:actor];
    if (vtcomp)
    {
        VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
        [tcomp setLocation:location];
    }
}

-(void)actorDragStart:(VMAEntity*)dragEntity location:(CGPoint)location;
{
    // suppress scene updates until entity animations have completed
    if (_actionsCompleted)
    {
        _draggedEntity = dragEntity;
        _dragStart = location;

        // Actor is being dragged, so if it currently occupies a dropzone, set that dropzone as now being unoccupied so that it
        // gets highlighted during drag/move operations.
        VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByDropZoneSlot:_dragStart occupied:YES];
        dzOcc.occupied = NO;
    }
}

-(void)actionCompleted
{
    _actionsCompleted = YES;
    //[self printDebugInfo];
}

-(void)actorDragStop:(CGPoint)location;
{
    _actionsCompleted = NO;
    SKAction* despawnAction = [SKAction performSelector:@selector(removeDraggedActor) onTarget:self];
    CGRect boatShedRect = [_scene getBoatShedRect];
    CGPoint targetLocBoatShed = CGPointMake(boatShedRect.origin.x + BOATSHEDOFFSET,
                                            (boatShedRect.origin.y + (boatShedRect.size.height / 2)));
    // if drag began at a drop zone...
    VMADropZone* dzUnocc = [[_scene getDropZoneManager] rectIntersectsUnoccupiedDropZoneSlot:[self actorFrameForEntity:_draggedEntity]];
    //__block VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByOccupiedDropZoneSlot:_dragStart];
    __block VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByDropZoneSlot:_dragStart occupied:NO];
    __weak VMALongshipManager* weakSelf = self;
    if (dzOcc != nil)
    {
        // ...test for intersections with boat shed...
        if (CGRectIntersectsRect(boatShedRect, [self actorFrameForEntity:_draggedEntity]))
        {
            [self animateDraggedActorFromLocation:location
                                       toLocation:targetLocBoatShed
                                       withAction:[SKAction runBlock:^
                                               {
                                                   [weakSelf removeDraggedActor];
                                                   dzOcc.occupied = NO;
                                                   [weakSelf actionCompleted];
                                               }]];
        }

        // ... and unoccupied drop zones...
        else if (dzUnocc != nil)
        {
            CGPoint targetLocDropZone = CGPointMake(dzUnocc.rect.origin.x + (dzUnocc.rect.size.width / 2),
                                                    dzUnocc.rect.origin.y + (dzUnocc.rect.size.height / 2));
            [self animateDraggedActorFromLocation:location
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
            [self animateDraggedActorFromLocation:location
                                       toLocation:_dragStart
                                       withAction:[SKAction runBlock:^{[weakSelf actionCompleted];}]];
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
            [self animateDraggedActorFromLocation:location
                                       toLocation:targetLocDropZone
                                       withAction:[SKAction runBlock:^{[weakSelf actionCompleted];}]];

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
            [self animateDraggedActorFromLocation:location
                                   toLocation:targetLocBoatShed
                                   withAction:despawnAction];
        }
    }
}

-(void)handleActorDrag:(CGPoint)location
{
    [self handleActorMove:location withEntity:_draggedEntity];
}

-(BOOL)actorHasBlockingAnimation:(VMAEntity*)entity
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

-(void)setAction:(SKAction*)action forActor:(VMAEntity*)actor withBlockingMode:(BOOL)blockMode
{
    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMAAnimatableComponent class]
                                                                   forEntity:actor];
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
