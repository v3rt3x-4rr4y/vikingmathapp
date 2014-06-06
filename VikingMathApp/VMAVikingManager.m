//
//  VMAVikingManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 14/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAVikingManager.h"

@implementation VMAVikingManager
{
    VMAGroupsActivityBuildScene* _scene;
}

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene;
{
    if (self = [super init])
    {
        _scene = invokingScene;
    }
    return self;
}

-(BOOL)draggingActor
{
    return NO;
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
    return nil;
}

-(void)handleActorMove:(CGPoint)location withEntity:(VMAEntity*)actor
{

}

-(void)actorDragStart:(VMAEntity*)dragEntity location:(CGPoint)location
{

}

-(void)handleActorDrag:(CGPoint)location
{

}

-(void)actorDragStop:(CGPoint)location
{

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
