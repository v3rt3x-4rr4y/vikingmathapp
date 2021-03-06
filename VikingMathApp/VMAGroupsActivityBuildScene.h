//
//  MyScene.h
//  VikingMathApp
//

//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class VMADropZoneManager;
@class VMALongshipManager;
@class VMAVikingPoolManager;

@interface VMAGroupsActivityBuildScene : SKScene

-(CGRect)getBoatShedRect;
-(CGRect)getOnPointZoneRect;
-(CGRect)getBoatProwRect;
-(void)handleHighlights;
-(VMADropZoneManager*)getDropZoneManager;
-(VMALongshipManager*)getLongshipManager;
-(VMAVikingPoolManager*)getPoolManager;

@end
