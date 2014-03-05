//
//  VMAEntityFactory.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"
#import "Physics.h"
#import "VMAEntityFactory.h"
#import "VMAEntityManager.h"
#import "VMATransformableComponent.h"
#import "VMARenderableComponent.h"
#import "VMAAnimatableComponent.h"

@implementation VMAEntityFactory
{
    VMAEntityManager* _entityManager;
    SKNode* _parentNode;
}

- (id)initWithEntityManager:(VMAEntityManager*)entityManager parentNode:(SKNode*)parentNode
{
    if ((self = [super init]))
    {
        _entityManager = entityManager;
        _parentNode = parentNode;
    }
    return self;
}

-(VMAEntity*)createLongshipAtLocation:(CGPoint)location
{
    SKSpriteNode* shipNode = [SKSpriteNode spriteNodeWithImageNamed:BOATNODENAME];
    VMAEntity* shipEntity = [_entityManager createEntity];

    // make it moveable, renderable, animatable
    [_entityManager addComponent:[[VMATransformableComponent alloc] initWithLocation:location] toEntity:shipEntity];
    [_entityManager addComponent:[[VMARenderableComponent alloc] initWithSprite:shipNode] toEntity:shipEntity];
    [_entityManager addComponent:[[VMAAnimatableComponent alloc] initWithAction:nil blocksUpdates:NO] toEntity:shipEntity];

    // sprite node name is set to its entity id
    shipNode.name = [NSString stringWithFormat:@"%@_%d", BOATNODENAME, shipEntity.eid];
    shipNode.anchorPoint = CGPointMake(0.5, 0.5);
    shipNode.position = location;

    // make a physics body for the boat prow
    CGSize contactSize = CGSizeMake(shipNode.size.width - 40, shipNode.size.height);
    shipNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
    // prevent movement due to physics
    shipNode.physicsBody.dynamic = NO;

    // give the boat prow a physics body category and collision mask:
    // category = what type of object is this ?
    // mask = what other types of object should this type of object collide with ?
    shipNode.physicsBody.categoryBitMask = VMAPhysicsCategoryLongship;
    shipNode.physicsBody.collisionBitMask = VMAPhysicsCategoryViking;

    // set the object categories which should trigger callbacks (begin, end) if they make contact with the cat
    shipNode.physicsBody.contactTestBitMask = VMAPhysicsCategoryViking;

    [_parentNode addChild:shipNode ];

    return shipEntity;
}

-(VMAEntity*)createLongshipForShipShed:(SKSpriteNode*)shipShedNode
{
    SKSpriteNode* shipNode = [SKSpriteNode spriteNodeWithImageNamed:BOATNODENAME];
    VMAEntity* shipProwEntity = [_entityManager createEntity];

    // sprite node name is set to its entity id
    shipNode.name = [NSString stringWithFormat:@"%d", shipProwEntity.eid];
    shipNode.anchorPoint = CGPointMake(0, 0);
    shipNode.position = CGPointMake(shipShedNode.position.x - shipNode.size.width / 2,
                                        (shipShedNode.position.y + (shipShedNode.size.height / 2)) - shipNode.size.height / 2);

    // make a physics body for the boat prow
    CGSize contactSize = CGSizeMake(shipNode.size.width - 40, shipNode.size.height);
    shipNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
    // prevent movement due to physics
    shipNode.physicsBody.dynamic = NO;

    // give the boat prow a physics body category and collision mask:
    // category = what type of object is this ?
    // mask = what other types of object should this type of object collide with ?
    shipNode.physicsBody.categoryBitMask = VMAPhysicsCategoryLongship;
    shipNode.physicsBody.collisionBitMask = VMAPhysicsCategoryViking;

    // set the object categories which should trigger callbacks (begin, end) if they make contact with the cat
    shipNode.physicsBody.contactTestBitMask = VMAPhysicsCategoryViking;

    [_parentNode addChild:shipNode ];

    return shipProwEntity;
}

-(VMAEntity*)createShipProwForShipShed:(SKSpriteNode*)shipShedNode
{
    SKSpriteNode* shipProwNode = [SKSpriteNode spriteNodeWithImageNamed:BOATPROWNODENAME];
    VMAEntity* shipProwEntity = [_entityManager createEntity];

    // sprite node name is set to its entity id
    shipProwNode.name = [NSString stringWithFormat:@"%@_%d", BOATPROWNODENAME, shipProwEntity.eid];
    shipProwNode.anchorPoint = CGPointMake(0, 0);
    shipProwNode.position = CGPointMake(shipShedNode.position.x - shipProwNode.size.width,
                                         (shipShedNode.position.y + (shipShedNode.size.height / 2)) - shipProwNode.size.height / 2);

    // make a physics body for the boat prow
    CGSize contactSize = CGSizeMake(shipProwNode.size.width - 40, shipProwNode.size.height);
    shipProwNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
    // prevent movement due to physics
    shipProwNode.physicsBody.dynamic = NO;

    // give the boat prow a physics body category and collision mask:
    // category = what type of object is this ?
    // mask = what other types of object should this type of object collide with ?
    shipProwNode.physicsBody.categoryBitMask = VMAPhysicsCategoryLongship;
    shipProwNode.physicsBody.collisionBitMask = VMAPhysicsCategoryViking;

    // set the object categories which should trigger callbacks (begin, end) if they make contact with the cat
    shipProwNode.physicsBody.contactTestBitMask = VMAPhysicsCategoryViking;

    [_parentNode addChild:shipProwNode ];

    return shipProwEntity;
}

-(VMAEntity*)createHighlightForRect:(CGRect)rect
{
    CGPathRef bodyPath = CGPathCreateWithRect(rect, nil);
    SKShapeNode* shape = [SKShapeNode node];
    shape.path = bodyPath;
    shape.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    shape.lineWidth = 1.0;
    [_parentNode addChild:shape];
    CGPathRelease(bodyPath);
    VMAEntity* highlightEntity = [_entityManager createEntity];
    [_entityManager addComponent:[[VMARenderableComponent alloc] initWithShape:shape] toEntity:highlightEntity];
    return highlightEntity;
}

@end
