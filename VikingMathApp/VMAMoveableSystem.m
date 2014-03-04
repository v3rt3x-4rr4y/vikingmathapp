//
//  VMAMoveableSystem.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAMoveableSystem.h"
#import "VMAEntityManager.h"
#import "VMAMoveableComponent.h"
#import "VMARenderableComponent.h"

@implementation VMAMoveableSystem

-(void)update:(double)dt
{
    // get all moveable components
    NSArray * entities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[VMAMoveableComponent class]];
    for (VMAEntity * entity in entities)
    {
        VMAMoveableComponent * moveComp = (VMAMoveableComponent *) [self.entityManager getComponentOfClass:[VMAMoveableComponent class]
                                                                                             forEntity:entity];

        VMARenderableComponent * renderComp = (VMARenderableComponent *) [self.entityManager getComponentOfClass:[VMARenderableComponent class]
                                                                                              forEntity:entity];
        [renderComp updateSpriteNode:[moveComp getLocation]];
    }
}

@end
