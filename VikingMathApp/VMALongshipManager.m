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
    SKAction* _dragSound;
    SKAction* _dropSound;
    SKAction* _creakSound;
}

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene
{
    if (self = [super init])
    {
        _scene = invokingScene;
        _longships = [NSMutableDictionary dictionary];
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _actionsCompleted = YES;
        _dragSound = [SKAction playSoundFileNamed:@"VikingMathApp_Drag.wav" waitForCompletion:NO];
        _dropSound = [SKAction playSoundFileNamed:@"VikingMathApp_BodyDrop.wav" waitForCompletion:NO];
        _creakSound = [SKAction playSoundFileNamed:@"VikingMathApp_Creak.wav" waitForCompletion:NO];
    }
    return self;
}

-(int)numDeployedLongships
{
    return (int)[[_longships allKeys] count];
}

-(NSArray*)deployedLongshipIds
{
    return [_longships allKeys];
}

-(NSMutableArray*)dataForLongshipInDropZone:(int)dropzoneIndex
{
    NSMutableArray* retVal = nil;
    for (NSObject* obj in [_longships allKeys])
    {
        NSMutableDictionary* dict = [_longships objectForKey:obj];
        if ([(NSNumber*)dict[DROP_ZONE_SLOT_INDEX_KEY] intValue] == dropzoneIndex)
        {
            retVal = [NSMutableArray arrayWithCapacity:2];
            [retVal insertObject:obj atIndex:0];
            [retVal insertObject:dict atIndex:1];
            break;
        }
    }
    return retVal;
}

-(int)numVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
{
    int retVal = -1;
    NSMutableArray* lsArray = [self dataForLongshipInDropZone:dropZoneId];
    if (lsArray)
    {
        retVal = [(NSNumber*)[lsArray[1] objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue];
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
    NSArray* lsArray = [self dataForLongshipInDropZone:dropZoneId];
    if (lsArray)
    {
        int val = 1 + [(NSNumber*)[lsArray[1] objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue];
        lsArray[1][NUM_ASSIGNED_VIKINGS_KEY] = [NSNumber numberWithInt:val];

        // Update the texture
        [self updateTexture:val forLongshipWithId:[(NSNumber*)lsArray[0] intValue]];

        NSLog(@"Longship in drop zone: %d now has: %d vikings on board", dropZoneId, val);
    }
}

-(void)decrementVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
{
    NSArray* lsArray = [self dataForLongshipInDropZone:dropZoneId];
    if (lsArray)
    {
        int val = [(NSNumber*)[lsArray[1] objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue] - 1;
        lsArray[1][NUM_ASSIGNED_VIKINGS_KEY] = [NSNumber numberWithInt:val];

        // Update the texture
        [self updateTexture:val forLongshipWithId:[(NSNumber*)lsArray[0] intValue]];

        NSLog(@"Longship in drop zone: %d now has: %d vikings on board", dropZoneId, val);
    }
}

-(void)updateLIFOVikingOpacityForLongshipInDropZone:(int)dropZoneId opaque:(BOOL)isOpaque;
{
    NSArray* lsArray = [self dataForLongshipInDropZone:dropZoneId];
    if (lsArray)
    {
        int val = [(NSNumber*)[lsArray[1] objectForKey:NUM_ASSIGNED_VIKINGS_KEY] intValue];
        NSString* strOpacity = isOpaque ? @"o" : @"";
        NSString* name = [NSString stringWithFormat:@"%@%d%@", BOATNODENAME, val, strOpacity];
        SKTexture* tex = [[_appDelegate entityFactory] getLongshipTexture:name];
        if (tex)
        {
            // Update the corresponding entity's renderable component
            uint32_t longshipId = [(NSNumber*)lsArray[0] intValue];
            VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                     forEntityWithId:longshipId];
            if (vrcomp)
            {
                VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
                [rcomp updateSpriteTexture:tex];
            }
        }
    }
}

-(void)updateTexture:(int)value forLongshipWithId:(uint32_t)longshipId
{
    SKTexture* tex = [[_appDelegate entityFactory] getLongshipTexture:[NSString stringWithFormat:@"%@%d", BOATNODENAME, value]];
    if (tex)
    {
        // Update the corresponding entity's renderable component
        VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                 forEntityWithId:longshipId];
        if (vrcomp)
        {
            VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
            [rcomp updateSpriteTexture:tex];
        }
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
    SKAction* moveAction = [SKAction moveTo:targetPoint duration:distance / TRANSLATE_VELOCITY_PIXELS_PER_SEC_FAST];
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
        [_scene runAction:_dragSound];
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
    CGRect boatShedRect = [_scene getBoatShedRect];
    CGPoint targetLocBoatShed = CGPointMake(boatShedRect.origin.x + BOATSHEDOFFSET,
                                            (boatShedRect.origin.y + (boatShedRect.size.height / 2)));
    // if drag began at a drop zone...
    VMADropZone* dzUnocc = [[_scene getDropZoneManager] rectIntersectsUnoccupiedDropZoneSlot:[self actorFrameForEntity:_draggedEntity]];
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
                                                   [_scene runAction:_creakSound];
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
                                       withAction:[SKAction runBlock:^{
                                                    [weakSelf actionCompleted];
                                                    [_scene runAction:_dropSound];}]];

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
                                       withAction:[SKAction runBlock:^{
                                                    [_scene runAction:_dropSound];
                                                    [weakSelf actionCompleted];}]];
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
                                       withAction:[SKAction runBlock:^{
                                                    [_scene runAction:_dropSound];
                                                    [weakSelf actionCompleted];}]];

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
                                       withAction:[SKAction runBlock:^
                                                   {
                                                       [_scene runAction:_creakSound];
                                                       [weakSelf removeDraggedActor];
                                                       [weakSelf actionCompleted];
                                                   }]];
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

-(void)setAction:(SKAction*)action forActorWithId:(uint32_t)id withBlockingMode:(BOOL)blockMode
{
    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMAAnimatableComponent class]
                                                                   forEntityWithId:id];
    if (vacomp)
    {
        VMAAnimatableComponent* acomp = (VMAAnimatableComponent*)vacomp;
        [acomp setAction:action withBlockingMode:YES];
    }
}

-(void)setAction:(SKAction*)action forActor:(VMAEntity*)actor withBlockingMode:(BOOL)blockMode
{
    [self setAction:action forActorWithId:actor.eid withBlockingMode:blockMode];
}

-(void)launchLongships
{
    CGFloat xOffscreen = -200.0f;
    int index = 1;
    for (NSObject* obj in [_longships allKeys])
    {
        unsigned int i = [(NSNumber*)obj intValue];
        VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                       forEntityWithId:i];
        if (vtcomp)
        {
            VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
            SKAction* moveAction = [SKAction moveTo:CGPointMake(xOffscreen, tcomp.location.y) duration:0.5];
            moveAction.timingMode = SKActionTimingEaseInEaseOut;
            SKAction* waitAction = [SKAction waitForDuration:0.1f * index];

            // animate the mobile longship to its destination and despawn
            [self setAction:[SKAction sequence:@[waitAction, moveAction]] forActorWithId:i withBlockingMode:YES];
            index++;
        }
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
