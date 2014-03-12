//
//  VMALongshipManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 06/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VMAEntity;
@class VMAGroupsActivityBuildScene;
@class VMADropZoneManager;

@interface VMALongshipManager : NSObject

@property (strong) VMAEntity* draggedEntity;
@property (assign) CGPoint dragStart;

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene;
-(BOOL)draggingLongship;
-(CGRect)draggedLongshipFrame;
-(void)removeDraggedLongship;
-(VMAEntity*)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug;
-(void)handleLongshipMove:(CGPoint)location withEntity:(VMAEntity*)longship;
-(void)longshipDragStart:(VMAEntity*)dragEntity location:(CGPoint)location;
-(void)handleLongshipDrag:(CGPoint)location;
-(void)longshipDragStop:(CGPoint)location;
-(BOOL)longshipHasBlockingAnimation:(VMAEntity*)entity;
-(void)setAction:(SKAction*)action forLongship:(VMAEntity*)longship withBlockingMode:(BOOL)blockMode;

/**
 Animates the entity currently being dragged to the supplied target location
 If an action is supplied, this is carried out after all other actions have been executed.
 @param dropPoint current location of entity
 @param targetPoint1 move to this location if intersection passes
 @param action SKAction to execute to after move animation actions have been carried out.
 @return YES = intersection test passed, NO = intersection test failed.
 */
-(void)animateLongshipFromLocation:(CGPoint)dropPoint
                        toLocation:(CGPoint)targetPoint
                        withAction:(SKAction*)action;

@end
