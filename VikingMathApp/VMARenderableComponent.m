//
//  VMARenderableComponent.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMARenderableComponent.h"
#import "VMAMathUtility.h"
#import <SpriteKit/SpriteKit.h>

@implementation VMARenderableComponent
{
    SKSpriteNode* _skSpriteNode;
    SKShapeNode* _skShapeNode;
}

-(instancetype)initWithSprite:(SKSpriteNode*)spriteNode isVisible:(BOOL)visible;
{
    if ((self = [super init]))
    {
        _skSpriteNode = spriteNode;
        _skShapeNode = nil;
        _isVisible = visible;
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

-(void)updateSpriteNode:(CGPoint)location rotation:(CGFloat)rotation;
{
    _skSpriteNode.position = location;
    _skSpriteNode.zRotation = rotation;// - DegreesToRadians(90.0f);
}

-(SKSpriteNode*)getSprite
{
    return _skSpriteNode;
}

-(void)updateSpriteTexture:(SKTexture*)texture
{
    _skSpriteNode.texture = texture;
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