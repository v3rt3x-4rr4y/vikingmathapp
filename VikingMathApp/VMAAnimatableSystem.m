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
#import "VMATransformableComponent.h"
#import "VMAEntityManager.h"

@implementation VMAAnimatableSystem

-(void)update:(double)dt
{
    // get all animatable components
    NSArray * entities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[VMAAnimatableComponent class]];
    for (VMAEntity * entity in entities)
    {
        VMAAnimatableComponent * animComp = (VMAAnimatableComponent*) [self.entityManager getComponentOfClass:[VMAAnimatableComponent class]
                                                                                                     forEntity:entity];
        VMARenderableComponent * renComp = (VMARenderableComponent*) [self.entityManager getComponentOfClass:[VMARenderableComponent class]
                                                                                                   forEntity:entity];
        SKAction* componentAction = [animComp getAction];
        if (componentAction)
        {
            // if the entity already has actions running, don't interfere with them.
            if ([[renComp getSprite] hasActions])
            {
                continue;
            }

            // build an action to update the TransformableComponent (position, rotation, scale, etc) on completion, as these may
            // have been changed by the animation actions that are being applied here.
             __weak VMAAnimatableSystem* weakSelf = self;
            SKAction* updateXformAction = [SKAction runBlock:^
            {
                VMATransformableComponent * xformComp =
                    (VMATransformableComponent*) [weakSelf.entityManager getComponentOfClass:[VMATransformableComponent class]
                                                                               forEntity:entity];
                xformComp.location = [renComp getSprite].position;
            }];

            // build an action to update the AnimatableComponent so it knows its animations have finished running.
            SKAction* finaliseAction = [SKAction runBlock:^{[animComp actionsDidComplete];}];

            SKAction* action = [SKAction sequence:@[componentAction, updateXformAction, finaliseAction]];
            [[renComp getSprite] runAction:action];
        }
    }
}

@end
