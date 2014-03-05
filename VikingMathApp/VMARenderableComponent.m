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
    SKShapeNode* _skShapeNode;
}

-(instancetype)initWithSprite:(SKSpriteNode*)spriteNode
{
    if ((self = [super init]))
    {
        _skSpriteNode = spriteNode;
        _skShapeNode = nil;
    }
    return self;
}

-(instancetype)initWithShape:(SKShapeNode*)shapeNode
{
    if ((self = [super init]))
    {
        _skShapeNode = shapeNode;
        _skSpriteNode = nil;
    }
    return self;
}

-(void)updateSpriteNode:(CGPoint)location
{
    _skSpriteNode.position = location;
}

-(SKSpriteNode*)getSprite
{
    return _skSpriteNode;
}

-(SKShapeNode*)getShape
{
    return _skShapeNode;
}

-(void)tearDown
{
    if (_skSpriteNode)
    {
        [_skSpriteNode removeFromParent];
    }
    if (_skShapeNode)
    {
        [_skShapeNode removeFromParent];
    }
}

@end