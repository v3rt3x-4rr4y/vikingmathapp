//
//  VMAEntityRenderableSystem.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 11/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "VMARenderableSystem.h"
#import "VMARenderableComponent.h"
#import "VMAEntityManager.h"
#import "VMAEntity.h"

@implementation VMARenderableSystem

-(void)update:(double)dt
{
    // get all renderable components
    NSArray * entities = [self.entityManager getAllEntitiesPosessingComponentOfClass:[VMARenderableComponent class]];
    for (VMAEntity * entity in entities)
    {
        VMARenderableComponent * renComp = (VMARenderableComponent*) [self.entityManager getComponentOfClass:[VMARenderableComponent class]
                                                                                                   forEntity:entity];
        [renComp getSprite].hidden = ![renComp isVisible];
    }
}

@end
