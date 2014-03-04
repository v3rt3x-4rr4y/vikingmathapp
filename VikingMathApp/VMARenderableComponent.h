//
//  VMARenderableComponent.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAComponent.h"
@class SKSpriteNode;

@interface VMARenderableComponent : VMAComponent

-(instancetype)initWithSprite:(SKSpriteNode*)spriteNode;
-(void)updateSpriteNode:(CGPoint)location;

@end
