//
//  MyScene.h
//  VikingMathApp
//

//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface VMAGroupsActivityBuildScene : SKScene

-(CGRect)getDropZoneRect;
-(CGRect)getBoatShedRect;
-(CGRect)getBoatProwRect;
-(void)handleHighlights;

@end
