//
//  VMARenderableComponent.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMARenderableComponent.h"
#import <SpriteKit/SpriteKit.h>

@implementation VMARenderableComponent
{
    SKSpriteNode* _skSpriteNode;
}

-(instancetype)initWithSprite:(SKSpriteNode*)spriteNode
{
    if ((self = [super init]))
    {
        _skSpriteNode = spriteNode;
    }
    return self;
}

-(void)updateSpriteNode:(CGPoint)location
{
    _skSpriteNode.position = location;
}

@end
