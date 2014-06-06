//
//  VMAVikingManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 14/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMAActorManager.h"

@class VMAGroupsActivityBuildScene;

@interface VMAVikingManager : NSObject <VMAActorManager>

@property (strong) VMAEntity* draggedEntity;
@property (assign) CGPoint dragStart;

@end
