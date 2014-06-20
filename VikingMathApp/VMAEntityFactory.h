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
@class SKTexture;
@class VMAEntity;
@class VMAEntityManager;

@interface VMAEntityFactory : NSObject

- (id)initWithEntityManager:(VMAEntityManager *)entityManager;

-(VMAEntity*)createLongshipForShipShed:(SKSpriteNode*)shipShedNode withParent:(SKNode*)parentNode;
-(VMAEntity*)createShipProwForShipShed:(SKSpriteNode*)shipShedNode withParent:(SKNode*)parentNode;
-(VMAEntity*)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parentNode name:(NSString*)name debug:(BOOL)debug;
-(VMAEntity*)createVikingAtLocation:(CGPoint)location withParent:(SKNode*)parentNode name:(NSString*)name debug:(BOOL)debug;
-(VMAEntity*)createHighlightForRect:(CGRect)rect withParent:(SKNode*)parentNode;
-(VMAEntity*)createDropzoneHighlightMaskForRect:(CGRect)rect withParent:(SKNode*)parentNode;
-(VMAEntity*)createBoatshedHighlightMaskForRect:(CGRect)rect withParent:(SKNode*)parentNode;
-(SKTexture*)getLongshipTexture:(NSString*)textureName;

@end
