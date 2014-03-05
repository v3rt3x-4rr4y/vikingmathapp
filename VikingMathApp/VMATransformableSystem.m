//
//  VMAMoveableSystem.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMATransformableSystem.h"
#import "VMAEntityManager.h"
#import "VMATransformableComponent.h"
#import "VMAAnimatableComponent.h"
#import "VMARenderableComponent.h"

@implementation VMATransformableSystem

-(void)update:(double)dt
{
    // get all moveable components
    NSArray * entities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[VMATransformableComponent class]];
    for (VMAEntity * entity in entities)
    {
        VMAAnimatableComponent * animComp = (VMAAnimatableComponent *) [self.entityManager getComponentOfClass:[VMAAnimatableComponent class]
                                                                                                       forEntity:entity];
        // only update if entity isn't currently being animated.
        if (![animComp hasBlockingAnimation])
        {
            VMATransformableComponent * moveComp =
                (VMATransformableComponent *) [self.entityManager getComponentOfClass:[VMATransformableComponent class]
                                                                            forEntity:entity];
            VMARenderableComponent * renComp =
            (VMARenderableComponent*) [self.entityManager getComponentOfClass:[VMARenderableComponent class]
                                                                        forEntity:entity];

            [renComp updateSpriteNode:[moveComp location]];
        }
    }
}

@end
