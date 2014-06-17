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
#import "VMAComponent.h"
#import "AppDelegate.h"

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
    return CGRectZero;
}

-(void)removeDraggedActor
{

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
    _dragStart = CGPointZero;
    _draggedEntity = nil;
}

-(BOOL)actorHasBlockingAnimation:(VMAEntity*)entity
{
    return NO;
}

-(void)setAction:(SKAction*)action forActor:(VMAEntity*)actor withBlockingMode:(BOOL)blockMode
{

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

}

@end
