//
//  MyScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 27/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAGroupsActivityBuildScene.h"

@implementation VMAGroupsActivityBuildScene

#pragma mark PRIVATE INSTANCE VARIABLES
{
    SKNode* _backgroundLayer;
    SKNode* _boatShedNode;
    SKNode* _boatProwNode;
    NSArray* _boats;

}

#pragma mark SCENE LIFE CYCLE

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // Create layer to act as parent
        _backgroundLayer = [SKNode node];
        [self addChild:_backgroundLayer];

        // Background sprite
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode* bground = [SKSpriteNode spriteNodeWithImageNamed:@"GroupVikingsActivity_Background"];
        bground.anchorPoint = CGPointZero; // set anchor point to lower left corner of sprite
        bground.position = CGPointMake(0, 0);
        [_backgroundLayer addChild:bground];

        // Add the boat house
        _boatShedNode = [SKNode node];
        SKSpriteNode* boatShed = [SKSpriteNode spriteNodeWithImageNamed:@"GroupActivity_BoatShed"];
        boatShed.anchorPoint = CGPointMake(0, 0);
        boatShed.position = CGPointMake(bground.size.width - boatShed.size.width - 10, 10);
        [_backgroundLayer addChild:boatShed];

        // Add the boat prow (drag source)
        _boatProwNode = [SKNode node];
        SKSpriteNode* boatProw = [SKSpriteNode spriteNodeWithImageNamed:@"GroupActivity_BoatProw"];
        boatProw.anchorPoint = CGPointMake(0, 0);
        boatProw.position = CGPointMake(boatShed.position.x - boatProw.size.width, (boatShed.position.y + (boatShed.size.height / 2)) - boatProw.size.height / 2);
        [_backgroundLayer addChild:boatProw];

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
