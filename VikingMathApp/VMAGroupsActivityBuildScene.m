//
//  MyScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 27/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAGroupsActivityBuildScene.h"
#import "Constants.h"
#import "Physics.h"
#import "VMAEntityManager.h"
#import "VMAEntityFactory.h"
#import "VMAMoveableComponent.h"
#import "VMAMoveableSystem.h"

@implementation VMAGroupsActivityBuildScene

#pragma mark PRIVATE INSTANCE VARIABLES
{
    SKNode* _backgroundLayer;
    SKSpriteNode* _boatShedNode;
    SKSpriteNode* _backgroundNode;
    NSArray* _staticLongships;
    VMAEntity* _mobileLongship;

    VMAEntityManager* _entityManager;
    VMAEntityFactory* _entityFactory;

    VMAMoveableSystem* _moveableSystem;
}

#pragma mark SCENE LIFE CYCLE

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // Create layer to act as parent
        _backgroundLayer = [SKNode node];
        [self addChild:_backgroundLayer];

        // Entity management
        _entityManager = [[VMAEntityManager alloc] init];
        _entityFactory = [[VMAEntityFactory alloc] initWithEntityManager:_entityManager parentNode:self];
        _moveableSystem = [[VMAMoveableSystem alloc] initWithEntityManager:_entityManager];

        // Background sprite
        self.backgroundColor = [SKColor whiteColor];
        _backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"GroupVikingsActivity_Background"];
        _backgroundNode.anchorPoint = CGPointZero; // set anchor point to lower left corner of sprite
        _backgroundNode.position = CGPointMake(0, 0);
        [_backgroundLayer addChild:_backgroundNode];

        // Add the boat house and the first boat
        _boatShedNode = [SKSpriteNode spriteNodeWithImageNamed:@"GroupActivity_BoatShed"];
        _boatShedNode.anchorPoint = CGPointMake(0, 0);
        _boatShedNode.position = CGPointMake(_backgroundNode.size.width - _boatShedNode.size.width - 10, 10);
        [_backgroundLayer addChild:_boatShedNode];

        // Add the boat prow (drag source)
        [_entityFactory createShipProwForShipShed:_boatShedNode];

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray* nodes = [self nodesAtPoint:location];
    for (SKNode* skNode in nodes)
    {
        if (!_mobileLongship && [skNode.name hasPrefix:BOATPROWNODENAME])
        {
            _mobileLongship = [_entityFactory createLongshipAtLocation:location];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray* nodes = [self nodesAtPoint:location];
    for (SKNode* skNode in nodes)
    {
        if (_mobileLongship)
        {
            // update location of mobile longship
            VMAComponent* comp = [_entityManager getComponentOfClass:[VMAMoveableComponent class] forEntity:_mobileLongship];
            if (comp)
            {
                VMAMoveableComponent* mcomp = (VMAMoveableComponent*)comp;
                [mcomp updateLocation:location];
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    [_moveableSystem update:currentTime];
}

@end
