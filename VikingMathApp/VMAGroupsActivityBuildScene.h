//
//  MyScene.h
//  VikingMathApp
//

//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class VMADropZoneManager;
@class VMALongshipManager;

@interface VMAGroupsActivityBuildScene : SKScene

-(CGRect)getBoatShedRect;
-(CGRect)getBoatProwRect;
-(void)handleHighlights;
-(VMADropZoneManager*)getDropZoneManager;
-(VMALongshipManager*)getLongshipManager;

@end
