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

-(instancetype)init;
-(BOOL)mobileLongshipIsActive;
-(CGRect)mobileLongshipFrame;
-(void)removeMobileLongship;
-(void)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug;
-(void)createMobileLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parent debug:(BOOL)debug;
-(void)handleLongshipMove:(CGPoint)location withEntity:(VMAEntity*)longship;
-(void)longshipDragStart:(VMAEntity*)dragEntity;
-(void)handleLongshipDrag:(CGPoint)location;
-(void)longshipDragStop;
-(BOOL)mobileLongshipHasBlockingAnimation;
-(void)setAction:(SKAction*)action forLongship:(VMAEntity*)longship withBlockingMode:(BOOL)blockMode;
-(VMAEntity*)longshipWithId:(uint32_t)eid;

@end
