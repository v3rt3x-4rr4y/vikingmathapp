//
//  VMALongshipManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 06/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMAActorManager.h"

@class VMAEntity;
@class VMAGroupsActivityBuildScene;
@class VMADropZoneManager;

@interface VMALongshipManager : NSObject <VMAActorManager>

@property (strong) VMAEntity* draggedEntity;
@property (assign) CGPoint dragStart;

-(int)numVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
-(int)numVikingsOnboardForLongshipWithId:(uint32_t)longshipId;
-(void)incrementVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
-(void)decrementVikingsOnboardForLongshipInDropZone:(int)dropZoneId;
-(void)updateLIFOVikingOpacityForLongshipInDropZone:(int)dropZoneId opaque:(BOOL)isOpaque;
-(int)numDeployedLongships;
-(NSArray*)deployedLongshipIds;
-(void)launchLongships;

@end
