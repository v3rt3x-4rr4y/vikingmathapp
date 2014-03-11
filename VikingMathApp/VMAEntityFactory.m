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
}

- (id)initWithEntityManager:(VMAEntityManager*)entityManager
{
    if ((self = [super init]))
    {
        _entityManager = entityManager;
    }
    return self;
}

-(VMAEntity*)createLongshipAtLocation:(CGPoint)location withParent:(SKNode*)parentNode name:(NSString*)name debug:(BOOL)debug;
{
    NSString* sprName = debug ? BOATNODENAMEDEBUG: BOATNODENAME;
    SKSpriteNode* shipNode = [SKSpriteNode spriteNodeWithImageNamed:sprName];
    VMAEntity* shipEntity = [_entityManager createEntity];

    // make it moveable, renderable, animatable
    [_entityManager addComponent:[[VMATransformableComponent alloc] initWithLocation:location] toEntity:shipEntity];
    [_entityManager addComponent:[[VMARenderableComponent alloc] initWithSprite:shipNode isVisible:YES] toEntity:shipEntity];
    [_entityManager addComponent:[[VMAAnimatableComponent alloc] initWithAction:nil blocksUpdates:NO] toEntity:shipEntity];

    // sprite node name is set to its entity id
    shipNode.name = [NSString stringWithFormat:@"%@%@_%d", name, BOATNODENAME, shipEntity.eid];
    shipNode.userData = [NSMutableDictionary dictionaryWithObjectsAndKeys:shipEntity, USERDATAENTITYIDKEY, @(NO), USERDATAENTITYISDRAGGINGKEY, nil];

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

#pragma mark DEBUG CODE
    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    label.text = shipNode.name;
    label.fontSize = 10.0f;
    [shipNode addChild:label];
#pragma mark -

    [parentNode addChild:shipNode ];

    return shipEntity;
}

-(VMAEntity*)createLongshipForShipShed:(SKSpriteNode*)shipShedNode withParent:(SKNode*)parentNode
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

    [parentNode addChild:shipNode ];

    return shipProwEntity;
}

-(VMAEntity*)createShipProwForShipShed:(SKSpriteNode*)shipShedNode  withParent:(SKNode*)parentNode
{
    SKSpriteNode* shipProwNode = [SKSpriteNode spriteNodeWithImageNamed:BOATPROWNODENAME];
    VMAEntity* shipProwEntity = [_entityManager createEntity];

    [_entityManager addComponent:[[VMARenderableComponent alloc] initWithSprite:shipProwNode isVisible:YES] toEntity:shipProwEntity];

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

    [parentNode addChild:shipProwNode ];

    return shipProwEntity;
}

-(VMAEntity*)createHighlightForRect:(CGRect)rect  withParent:(SKNode*)parentNode
{
    CGPathRef bodyPath = CGPathCreateWithRect(rect, nil);
    SKShapeNode* shape = [SKShapeNode node];
    shape.path = bodyPath;
    shape.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0 alpha:0.5];
    shape.lineWidth = 1.0;
    [parentNode addChild:shape];
    CGPathRelease(bodyPath);
    VMAEntity* highlightEntity = [_entityManager createEntity];
    [_entityManager addComponent:[[VMARenderableComponent alloc] initWithShape:shape] toEntity:highlightEntity];
    return highlightEntity;
}

-(VMAEntity*)createHighlightMaskForRect:(CGRect)rect withParent:(SKNode*)parentNode
{
    SKSpriteNode* hiliteSprite = [SKSpriteNode spriteNodeWithImageNamed:BOATHILITENODENAME];
    hiliteSprite.physicsBody.dynamic = NO;
    hiliteSprite.anchorPoint = CGPointMake(0.5, 0.5);
    hiliteSprite.position = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height  / 2));
     VMAEntity* highlightEntity = [_entityManager createEntity];
    [_entityManager addComponent:[[VMARenderableComponent alloc] initWithSprite:hiliteSprite isVisible:NO] toEntity:highlightEntity];
    
    hiliteSprite.name = [NSString stringWithFormat:@"%@_%d", BOATHILITENODENAME, highlightEntity.eid];
    [parentNode addChild:hiliteSprite];
    return highlightEntity;
}
@end
