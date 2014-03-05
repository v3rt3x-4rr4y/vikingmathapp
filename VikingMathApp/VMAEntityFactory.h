//
//  VMAEntityFactory.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKNode;
@class SKSpriteNode;
@class VMAEntity;
@class VMAEntityManager;

@interface VMAEntityFactory : NSObject

- (id)initWithEntityManager:(VMAEntityManager *)entityManager parentNode:(SKNode*)parentNode;

-(VMAEntity*)createLongshipAtLocation:(CGPoint)location;
-(VMAEntity*)createShipProwForShipShed:(SKSpriteNode*)shipShedNode;
-(VMAEntity*)createLongshipForShipShed:(SKSpriteNode*)shipShedNode;
-(VMAEntity*)createHighlightForRect:(CGRect)rect;

@end
