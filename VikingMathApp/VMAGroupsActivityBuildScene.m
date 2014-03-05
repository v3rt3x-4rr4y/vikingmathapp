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
#import "VMAAnimatableComponent.h"
#import "VMARenderableComponent.h"
#import "VMATransformableComponent.h"
#import "VMATransformableSystem.h"
#import "VMAAnimatableSystem.h"

@implementation VMAGroupsActivityBuildScene
{

#pragma mark PRIVATE INSTANCE VARS

    CGRect _longshipDropZone;
    CGFloat _longshipHeight;

    SKNode* _backgroundLayer;
    SKSpriteNode* _boatShedNode;
    SKSpriteNode* _backgroundNode;
    NSArray* _staticLongships;

    VMAEntity* _mobileLongship;
    VMAEntity* _dropZoneHighlight;

    VMAEntityManager* _entityManager;
    VMAEntityFactory* _entityFactory;

    VMATransformableSystem* _transformableSystem;
    VMAAnimatableSystem* _animatableSystem;
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
        _transformableSystem = [[VMATransformableSystem alloc] initWithEntityManager:_entityManager];
        _animatableSystem = [[VMAAnimatableSystem alloc] initWithEntityManager:_entityManager];

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

        // Add the boat prow
        [_entityFactory createShipProwForShipShed:_boatShedNode];

        // initialise long ship drop zone (use a temp longship sprite for dimensions)
        SKSpriteNode* tempShip = [SKSpriteNode spriteNodeWithImageNamed:BOATNODENAME];
        _longshipHeight = tempShip.size.height;
        _longshipDropZone = CGRectMake(10, _backgroundNode.size.height - _longshipHeight - 20,
                                       tempShip.size.width + 10, _longshipHeight + 10);
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime
{
    [_transformableSystem update:currentTime];
    [_animatableSystem update:currentTime];
}

#pragma mark TOUCH EVENT HANDLERS

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self handleTouches:touches withEvent:event eventType:VMATouchEventTypeBegan];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self handleTouches:touches withEvent:event eventType:VMATouchEventTypeMoved];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self handleTouches:touches withEvent:event eventType:VMATouchEventTypeEnded];
}

-(void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event eventType:(VMATouchEventType)type
{
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray* nodes = [self nodesAtPoint:location];
    for (SKNode* skNode in nodes)
    {
        switch (type)
        {
            case VMATouchEventTypeBegan:
            {
                if (!_mobileLongship && [skNode.name hasPrefix:BOATPROWNODENAME])
                {
                    _mobileLongship = [_entityFactory createLongshipAtLocation:location];
                }
            }
            break;

            case VMATouchEventTypeMoved:
            {
                if (_mobileLongship)
                {
                    // update location of mobile longship
                    [self handleMobileLongshipMove:location];

                    // update drop zone highlight
                    [self handleDropZoneHighlight];
                }
            }
            break;

            case VMATouchEventTypeEnded:
            {
                if (_mobileLongship)
                {
                    [self dropMobileLongship:(CGPoint)location];
                }
            }
            break;

            default:
            {

            }
            break;
        }
    }
}

#pragma mark UTILITY METHODS

-(void)handleMobileLongshipMove:(CGPoint)location
{
    VMAComponent* vtcomp = [_entityManager getComponentOfClass:[VMATransformableComponent class] forEntity:_mobileLongship];
    if (vtcomp)
    {
        VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
        [tcomp setLocation:location];
    }
}

-(void)handleDropZoneHighlight
{
    // see if drop zone needs highlighting
    VMAComponent* vrcomp = [_entityManager getComponentOfClass:[VMARenderableComponent class] forEntity:_mobileLongship];
    if (vrcomp)
    {
        VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
        if (CGRectIntersectsRect([rcomp getSprite].frame, _longshipDropZone))
        {
            if (!_dropZoneHighlight)
            {
                //NSLog(@"highlight ON");
                _dropZoneHighlight = [_entityFactory createHighlightForRect:_longshipDropZone];
            }
        }
        else
        {
            if (_dropZoneHighlight)
            {
                //NSLog(@"highlight OFF");
                [_entityManager removeEntity:_dropZoneHighlight];
                _dropZoneHighlight = nil;
            }
        }
    }
}

-(void)dropMobileLongship:(CGPoint)location
{
    // depending on dropped location of mobile longship, decide whether to send it back to shed
    // or position at the next availabel slot on shoreline.
    VMAComponent* vacomp = [_entityManager getComponentOfClass:[VMAAnimatableComponent class] forEntity:_mobileLongship];
    if (vacomp)
    {
        VMAAnimatableComponent* acomp = (VMAAnimatableComponent*)vacomp;
        if ([acomp hasBlockingAnimation])
        {
            return;
        }
        CGRect mobileRect = CGRectNull;
        CGPoint targetLoc = CGPointZero;
        SKAction* dropAction = nil;

        VMAComponent* vrcomp = [_entityManager getComponentOfClass:[VMARenderableComponent class] forEntity:_mobileLongship];
        if (vrcomp)
        {
            VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
            mobileRect = [rcomp getSprite].frame;
            if (CGRectIntersectsRect(_longshipDropZone, mobileRect))
            {
                // TODO: get drop zone highlight shape position, then send longship to dropzone
                targetLoc = CGPointMake(_longshipDropZone.origin.x + (_longshipDropZone.size.width / 2),
                                        _longshipDropZone.origin.y + (_longshipDropZone.size.height / 2));

                // update drop zone rect to next slot
                [self updateDropZoneWithIncrement:YES];
            }
            else
            {

                // anmimate longship back to shed
                targetLoc = CGPointMake(_boatShedNode.position.x + 90,
                                        (_boatShedNode.position.y + (_boatShedNode.size.height / 2)));
            }

            // detemine velocity based on distance
            double distance = sqrt(pow((targetLoc.x - location.x), 2.0) + pow((targetLoc.y - location.y), 2.0));

            // build move and despawn actions
            SKAction* moveAction = [SKAction moveTo:targetLoc duration:distance/TRANSLATE_VELOCITY_PIXELS_PER_SEC];
            dropAction = [SKAction sequence:@[moveAction,
                                              [SKAction waitForDuration:0.2],
                                              [SKAction performSelector:@selector(removeMobileLongship)
                                                               onTarget:self]]];
            [acomp setAction:dropAction withBlockingMode:YES];

            // update the drop zone highlight state
            [self handleDropZoneHighlight];
        }
    }
}

-(void)removeMobileLongship
{
    [_entityManager removeEntity:_mobileLongship];
    _mobileLongship = nil;
}

-(void)updateDropZoneWithIncrement:(BOOL)increment
{
    CGFloat delta = increment ? -_longshipHeight : _longshipHeight;
    _longshipDropZone = CGRectMake(_longshipDropZone.origin.x,
                                   _longshipDropZone.origin.y + delta - 20,
                                   _longshipDropZone.size.width,
                                   _longshipDropZone.size.height);

}


@end
