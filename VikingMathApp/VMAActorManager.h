//
//  VMAActorManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 14/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#ifndef VikingMathApp_VMAActorManager_h
#define VikingMathApp_VMAActorManager_h

#import "VMAEntity.h"

@class SKScene;
@class SKNode;
@class SKAction;

@protocol VMAActorManager

@property (strong) VMAEntity* draggedEntity;
@property (assign) CGPoint dragStart;

-(instancetype)initWithScene:(SKScene*)invokingScene;
-(BOOL)draggingActor;
-(CGRect)draggedActorFrame;
-(void)removeDraggedActor;
-(VMAEntity*)createActorAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug;
-(void)handleActorMove:(CGPoint)location withEntity:(VMAEntity*)actor;
-(void)actorDragStart:(VMAEntity*)dragEntity location:(CGPoint)location;
-(void)handleActorDrag:(CGPoint)location;
-(void)actorDragStop:(CGPoint)location;
-(BOOL)actorHasBlockingAnimation:(VMAEntity*)entity;
-(void)setAction:(SKAction*)action forActor:(VMAEntity*)actor withBlockingMode:(BOOL)blockMode;

/**
 Animates the entity currently being dragged to the supplied target location
 If an action is supplied, this is carried out after all other actions have been executed.
 @param dropPoint current location of entity
 @param targetPoint1 move to this location if intersection passes
 @param action SKAction to execute to after move animation actions have been carried out.
 */
-(void)animateDraggedActorFromLocation:(CGPoint)dropPoint
                            toLocation:(CGPoint)targetPoint
                            withAction:(SKAction*)action;
@end

#endif
