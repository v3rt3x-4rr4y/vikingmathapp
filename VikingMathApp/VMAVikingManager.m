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
#import "VMAComponent.h"
#import "VMADropZonemanager.h"
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

        // TODO: Viking is being dragged, so if it is currently onboard a longship, decrement the viking count on that longship.

    }
}

-(void)handleActorDrag:(CGPoint)location
{
    [self handleActorMove:location withEntity:_draggedEntity];
}

-(void)actorDragStop:(CGPoint)location
{
    _actionsCompleted = NO;
    SKAction* despawnAction = [SKAction performSelector:@selector(removeDraggedActor) onTarget:self];
    CGRect onPointZoneRect = [_scene getOnPointZoneRect];
    CGPoint targetLocOnPointZone = CGPointMake(VIKINGONPOINTXPOS + 100, VIKINGONPOINTYPOS);

    // if drag began at a longship (ie an occupied drop zone slot)...
    __block VMADropZone* dzOcc = [[_scene getDropZoneManager] pointContainedByDropZoneSlot:_dragStart occupied:YES];
    __weak VMAVikingManager* weakSelf = self;

    if (dzOcc != nil)
    {
        // ...test for intersections with the viking pool...
        if ([self actorFrameForEntity:_draggedEntity].origin.x > (VIKINGONPOINTXPOS + 10))
        {
            [self animateDraggedActorFromLocation:location
                                       toLocation:targetLocOnPointZone
                                       withAction:[SKAction runBlock:^
                                                   {
                                                       [weakSelf removeDraggedActor];
                                                       [weakSelf actionCompleted];
                                                   }]];
        }


        /*      TODO:
 

        // ... and longships which have space left onboard...
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
*/


        // ... otherwise animate back to the drag start location (ie the original longship) and de-spawn
        else
        {
            [self animateDraggedActorFromLocation:location
                                       toLocation:_dragStart
                                       withAction:[SKAction runBlock:^{[weakSelf actionCompleted];}]];
            _dragStart = CGPointZero;
            _draggedEntity = nil;
        }
    }

    // else if dragstart location intersects the on-point zone...
    else if (CGRectContainsPoint([_scene getOnPointZoneRect], _dragStart))
    {


        // TODO:...test for intersections with longships which have space left on board
        if (despawnAction)
        {
            // (1) despawn viking (2) increment longship's viking count
            [self removeDraggedActor];
        }
        // ... otherwise animate back to the pool zone and despawn
        else
        {
            [self animateDraggedActorFromLocation:location
                                       toLocation:targetLocOnPointZone
                                       withAction:despawnAction];
        }
    }
    else
    {
        [self removeDraggedActor];
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

    // animate the mobile longship to its destination and despawn
    [self setAction:dropAction forActor:_draggedEntity withBlockingMode:YES];
}

-(void)actionCompleted
{
    _actionsCompleted = YES;
    //[self printDebugInfo];
}

@end
