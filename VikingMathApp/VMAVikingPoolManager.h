//
//  VMAVikingPoolManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 23/06/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VMAGroupsActivityBuildScene.h"

@class SKScene;

@interface VMAVikingPoolManager : NSObject

-(instancetype)initWithScene:(SKScene*)invokingScene
                  numVikings:(int)vikings
                      bounds:(CGRect)poolBounds
                     onPoint:(CGPoint)location
                  parentNode:(SKNode*)parent;

-(void)addVikingToPool;
-(void)removeVikingFromPool;
-(void)advanceVikingToOnPoint;
-(void)layoutVikings:(BOOL)randomise;
-(NSUInteger)numVikingsInPool;
-(void)updateVikings:(NSTimeInterval)elapsedTime;

@end
