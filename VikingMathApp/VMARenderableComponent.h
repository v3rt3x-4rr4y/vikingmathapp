//
//  VMARenderableComponent.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAComponent.h"
@class SKSpriteNode;
@class SKShapeNode;

@interface VMARenderableComponent : VMAComponent

-(instancetype)initWithSprite:(SKSpriteNode*)spriteNode;
-(instancetype)initWithShape:(SKShapeNode*)shapeNode;
-(void)updateSpriteNode:(CGPoint)location;
-(SKSpriteNode*)getSprite;
-(SKShapeNode*)getShape;

@end
