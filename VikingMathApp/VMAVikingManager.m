//
//  VMAVikingManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 14/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAVikingManager.h"
#import "VMAEntityFactory.h"
#import "VMAEntitymanager.h"
#import "VMATransformableComponent.h"
#import "VMARenderableComponent.h"
#import "VMAAnimatableComponent.h"
#import "VMAMathUtility.h"
#import "VMADropZone.h"
#import "VMAComponent.h"
#import "VMADropZonemanager.h"
#import "VMALongshipManager.h"
#import "VMAVikingPoolManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Physics.h"

@implementation VMAVikingManager
{
    NSMutableDictionary* _vikings;
    AppDelegate* _appDelegate;
    VMAGroupsActivityBuildScene* _scene;
    BOOL _actionsCompleted;
}

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene
{
    if (self = [super init])
    {
        _scene = invokingScene;
        _vikings = [NSMutableDictionary dictionary];
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _actionsCompleted = YES;
    }
    return self;
}

-(BOOL)draggingActor
{
    return _draggedEntity != nil;
}

-(CGRect)draggedActorFrame
{
    return [self actorFrameForEntity:_draggedEntity];
}

-(void)removeDraggedActor
{
    [_vikings removeObjectForKey:@(_draggedEntity.eid)];
    [[_appDelegate entityManager] removeEntity:_draggedEntity];
    NSLog(@"Removed viking with ID: %d", _draggedEntity.eid);
    _actionsCompleted = YES;
    _dragStart = CGPointZero;
    _draggedEntity = nil;
}

-(VMAEntity*)createActorAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug
{
    // can only create a new viking if we've finished dragging the current viking
    if (_draggedEntity)
    {
        return nil;
    }

    VMAEntity* viking = [[_appDelegate entityFactory] createVikingAtLocation:location
                                                                    withParent:parent
                                                                          name:@""
                                                                         debug:debug];

    VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                   forEntity:viking];
    if (vtcomp)
    {
        VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
        [tcomp setRotation:DegreesToRadians(90.0f)];
    }

    // setting a placeholder (zero interger value) as the object for now
    [_vikings setObject:[NSNumber numberWithInt:0] forKey:@(viking.eid)];
    return viking;
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

-(void)actorDragStart:(VMAEntity*)dragEntity location:(CGPoint)location
{
    // suppress scene updates until entity animations have completed
    if (_actionsCompleted)
    {
        _draggedEntity = dragEntity;
        _dragStart = location;

        // If deag start began at the on-point zone, despwan the on-point viking
        if (CGRectContainsPoint([_scene getOnPointZoneRect], _dragStart))
        {
            // update the viking pool
            [[_scene getPoolManager] removeVikingFromPool];
            return;
        }

        // If drag started at an occupied longship, change the sprite texture to make LIFO viking opaque
        VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByDropZoneSlot:_dragStart occupied:YES];
        if (dzOcc)
        {
            [[_scene getLongshipManager] updateLIFOVikingOpacityForLongshipInDropZone:[dzOcc index] opaque:YES];
        }
    }
}

-(void)handleActorDrag:(CGPoint)location
{
    [self handleActorMove:location withEntity:_draggedEntity];
}

-(void)actorDragStop:(CGPoint)location
{
    _actionsCompleted = NO;
    CGPoint targetLocOnPointZone = CGPointMake(VIKINGONPOINTXPOS + 100, VIKINGONPOINTYPOS);
    __block VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByDropZoneSlot:_dragStart occupied:YES];
    __block VMADropZone* dzDrop = [[_scene getDropZoneManager] pointContainedByDropZoneSlot:location occupied:YES];
    int numVikingsTarget = [[_scene getLongshipManager] numVikingsOnboardForLongshipInDropZone:[dzDrop index]];
    int numVikings = [[_scene getLongshipManager] numVikingsOnboardForLongshipInDropZone:[dzOcc index]];
    __weak VMAVikingManager* weakSelf = self;

    // if dragged viking drag-start began at a longship (ie an occupied drop zone slot) AND that longship has > 1 viking onboard...
    if (dzOcc != nil && numVikings > 0)
    {
        // ...if the dragged viking drag-stop location intersects with the viking pool...
        if ([self actorFrameForEntity:_draggedEntity].origin.x > (VIKINGONPOINTXPOS + 10))
        {
            // ... animate dragged viking to the centre of viking pool and despawn
            [self animateDraggedActorFromLocation:location
                                       toLocation:targetLocOnPointZone
                                       withAction:[SKAction runBlock:^
                                                   {
                                                       [[_scene getLongshipManager] decrementVikingsOnboardForLongshipInDropZone:[dzOcc index]];
                                                       [[_scene getPoolManager] addVikingToPool];
                                                       [weakSelf removeDraggedActor];
                                                       [weakSelf actionCompleted];
                                                   }]];
        }

        // ... else if the dragged viking drag-stop location intersects another longship...
        else if (dzOcc != nil && dzDrop != nil)
        {
            // ...if the longship in the drag-stop dropzone has viking space onboard...
            int numVikingsDrop = [[_scene getLongshipManager] numVikingsOnboardForLongshipInDropZone:[dzDrop index]];
            if (numVikingsDrop >= 0 && numVikingsDrop < MAXVIKINGSPERLONGSHIP)
            {
                // ... decrement viking count in source longship, increment viking count in target longship, animate
                // dragged viking to target longship
                CGPoint targetLocDropZone = CGPointMake(dzDrop.rect.origin.x + (dzDrop.rect.size.width / 2),
                                                        dzDrop.rect.origin.y + (dzDrop.rect.size.height / 2));
                [self animateDraggedActorFromLocation:location
                                           toLocation:targetLocDropZone
                                           withAction:[SKAction runBlock:^
                                                       {
                                                           [[_scene getLongshipManager] decrementVikingsOnboardForLongshipInDropZone:[dzOcc index]];
                                                           [[_scene getLongshipManager] incrementVikingsOnboardForLongshipInDropZone:[dzDrop index]];
                                                           [[_scene getPoolManager] advanceVikingToOnPoint];
                                                           [weakSelf removeDraggedActor];
                                                           [weakSelf actionCompleted];
                }]];
            }
            // ... otherwise animate back to the drag start location (ie the original longship) and de-spawn
            else
            {
                [self animateDraggedActorFromLocation:location
                                           toLocation:_dragStart
                                           withAction:[SKAction runBlock:^
                                                       {
                                                           [weakSelf removeDraggedActor];
                                                           [weakSelf actionCompleted];
                                                       }]];
            }
        }

        // ... otherwise animate back to the drag start location (ie the original longship) and de-spawn
        else
        {
            [self animateDraggedActorFromLocation:location
                                       toLocation:_dragStart
                                       withAction:[SKAction runBlock:^
                                                   {
                                                       [[_scene getLongshipManager] updateLIFOVikingOpacityForLongshipInDropZone:[dzOcc index] opaque:NO];
                                                       [weakSelf removeDraggedActor];
                                                       [weakSelf actionCompleted];
                                                   }]];
        }
    }

    // else if dragged viking drag-start location intersects the viking on-point zone...
    else if (CGRectContainsPoint([_scene getOnPointZoneRect], _dragStart))
    {
        // ... and if the dragged viking drop location intersects a with an occupied dropzone
        // AND the longship in that dropzone has viking space left on board...
        if (dzDrop && numVikingsTarget >= 0 && numVikingsTarget < MAXVIKINGSPERLONGSHIP)
        {
            // .. if it does, increment longship's viking count and despawn the dragged viking
            [[_scene getLongshipManager] incrementVikingsOnboardForLongshipInDropZone:[dzDrop index]];
            [[_scene getPoolManager] advanceVikingToOnPoint];
            [self removeDraggedActor];
        }
        // ... otherwise animate the dragged viking back to the pool zone and despawn
        else
        {
            [self animateDraggedActorFromLocation:location
                                       toLocation:targetLocOnPointZone
                                       withAction:[SKAction runBlock:^
                                                   {
                                                       [weakSelf removeDraggedActor];
                                                       [[_scene getPoolManager] addVikingToPool];
                                                       [[_scene getPoolManager] advanceVikingToOnPoint];
                                                       [weakSelf actionCompleted];
                                                   }]];
        }
    }
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

/**
 Animates the entity currently being dragged to the supplied target location
 If an action is supplied, this is carried out after all other actions have been executed.
 @param dropPoint current location of entity
 @param targetPoint1 move to this location if intersection passes
 @param action SKAction to execute to after move animation actions have been carried out.
 */
-(void)animateDraggedActorFromLocation:(CGPoint)dropPoint
                            toLocation:(CGPoint)targetPoint
                            withAction:(SKAction*)action
{
    if ([self actorHasBlockingAnimation:_draggedEntity])
    {
        // viking is already being animated so do nothing
        return;
    }

    // determine action velocity based on distance
    double distance = sqrt(pow((targetPoint.x - dropPoint.x), 2.0) + pow((targetPoint.y - dropPoint.y), 2.0));

    // build move and despawn actions
    SKAction* moveAction = [SKAction moveTo:targetPoint duration:distance / TRANSLATE_VELOCITY_PIXELS_PER_SEC];
    moveAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* waitAction = [SKAction waitForDuration:DESPAWN_DELAY];
    SKAction* dropAction = action ? [SKAction sequence:@[moveAction, waitAction, action]] : [SKAction sequence:@[moveAction, waitAction]];

    // animate the viking to its destination and despawn
    [self setAction:dropAction forActor:_draggedEntity withBlockingMode:YES];
}

-(void)actionCompleted
{
    _actionsCompleted = YES;
    //[self printDebugInfo];
}

@end
