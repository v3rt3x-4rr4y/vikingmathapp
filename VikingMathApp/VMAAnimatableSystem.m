//
//  VMAAnimatableSystem.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 05/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "VMAAnimatableSystem.h"
#import "VMAAnimatableComponent.h"
#import "VMARenderableComponent.h"
#import "VMAEntityManager.h"

@implementation VMAAnimatableSystem

-(void)update:(double)dt
{
    // run the current action
    // get all moveable components
    NSArray * entities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[VMAAnimatableComponent class]];
    for (VMAEntity * entity in entities)
    {
        VMAAnimatableComponent * animComp = (VMAAnimatableComponent*) [self.entityManager getComponentOfClass:[VMAAnimatableComponent class]
                                                                                                     forEntity:entity];
        VMARenderableComponent * renComp = (VMARenderableComponent*) [self.entityManager getComponentOfClass:[VMARenderableComponent class]
                                                                                                     forEntity:entity];

        // only update if entity isn't currently being animated.
        SKAction* action = [animComp getAction];
        if (action)
        {
            [[renComp getSprite] runAction:action];
        }
    }
}


@end
