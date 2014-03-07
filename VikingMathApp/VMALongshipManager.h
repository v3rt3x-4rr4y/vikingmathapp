//
//  VMALongshipManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 06/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VMAEntity;

@interface VMALongshipManager : NSObject

@property (strong) VMAEntity* mobileLongship;
@property (strong) VMAEntity* draggedEntity;
@property (assign) CGPoint dragStart;

-(instancetype)init;
-(BOOL)mobileLongshipIsActive;
-(CGRect)mobileLongshipFrame;
-(CGRect)draggedLongshipFrame;
-(void)removeMobileLongship;
-(void)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug;
-(void)createMobileLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug;
-(void)handleLongshipMove:(CGPoint)location withEntity:(VMAEntity*)longship;
-(void)longshipDragStart:(VMAEntity*)dragEntity location:(CGPoint)location;
-(void)handleLongshipDrag:(CGPoint)location;
-(void)longshipDragStop;
-(BOOL)longshipHasBlockingAnimation:(VMAEntity*)entity;
-(void)setAction:(SKAction*)action forLongship:(VMAEntity*)longship withBlockingMode:(BOOL)blockMode;
-(VMAEntity*)longshipWithId:(uint32_t)eid;

/**
 Tests whether the supplied entity intersects with the supplied test area. If is does, the entity is animated to
 target point 1. If it does not, the entity is animated to target point 2.

 @param longshipEntity the entity to be handled
 @param intersectRect1 rectangle of area to test for intersection
 @param intersectRect2 rectangle of entity
 @param dropPoint current location of entity
 @param targetPoint1 move to this location if intersection passes
 @param targetPoint2 move to this location if intersection fails
 @param action SKAction to execute to after move animation actions have been carried out.
 @return YES = intersection test passed, NO = intersection test failed.
 */
-(BOOL)dropLongship:(VMAEntity*)longshipEntity
              rect1:(CGRect)intersectRect1
              rect2:(CGRect)intersectRect2
               drop:(CGPoint)dropPoint
             point1:(CGPoint)targetPoint1
             point2:(CGPoint)targetPoint2
         withAction:(SKAction*)action;

@end
