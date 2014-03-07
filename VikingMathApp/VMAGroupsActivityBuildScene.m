//
//  MyScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 27/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAGroupsActivityBuildScene.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Physics.h"
#import "VMALongshipManager.h"
#import "VMAEntityManager.h"
#import "VMAEntityFactory.h"
#import "VMAAnimatableComponent.h"
#import "VMARenderableComponent.h"
#import "VMATransformableComponent.h"
#import "VMATransformableSystem.h"
#import "VMAAnimatableSystem.h"

@implementation VMAGroupsActivityBuildScene
{
    CGRect _longshipDropZone;
    CGFloat _longshipHeight;

    SKNode* _backgroundLayer;
    SKSpriteNode* _boatShedNode;
    SKSpriteNode* _backgroundNode;

    VMAEntity* _dropZoneHighlight;
    //VMAEntityManager* _entityManager;
    //VMAEntityFactory* _entityFactory;
    VMALongshipManager* _longshipManager;

    VMATransformableSystem* _transformableSystem;
    VMAAnimatableSystem* _animatableSystem;

    AppDelegate* _appDelegate;
}

#pragma mark SCENE LIFE CYCLE

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

        // Create layer to act as parent
        _backgroundLayer = [SKNode node];
        [self addChild:_backgroundLayer];

        // Entity management
        //_entityManager = [[VMAEntityManager alloc] init];
        //_entityFactory = [[VMAEntityFactory alloc] initWithEntityManager:_entityManager];

        _transformableSystem = [[VMATransformableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _animatableSystem = [[VMAAnimatableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _longshipManager = [[VMALongshipManager alloc] init];

        // Background sprite
        self.backgroundColor = [SKColor whiteColor];
        _backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:BACKGROUND];
        _backgroundNode.anchorPoint = CGPointZero; // set anchor point to lower left corner of sprite
        _backgroundNode.position = CGPointMake(0, 0);
        [_backgroundLayer addChild:_backgroundNode];

        // Add the ship shed
        _boatShedNode = [SKSpriteNode spriteNodeWithImageNamed:BOATSHEDNODENAME];
        _boatShedNode.anchorPoint = CGPointMake(0, 0);
        _boatShedNode.position = CGPointMake(_backgroundNode.size.width - _boatShedNode.size.width - DROPZONEOFFSET, DROPZONEOFFSET);
        [_backgroundLayer addChild:_boatShedNode];

        // Add the ship prow (drag source)
        [[_appDelegate entityFactory] createShipProwForShipShed:_boatShedNode withParent:self];

        // initialise long ship drop zone (use a temp longship sprite for dimensions)
        SKSpriteNode* tempShip = [SKSpriteNode spriteNodeWithImageNamed:BOATNODENAME];
        _longshipHeight = tempShip.size.height;
        _longshipDropZone = CGRectMake(DROPZONEOFFSET, _backgroundNode.size.height - _longshipHeight - 2 * DROPZONEOFFSET,
                                       tempShip.size.width + DROPZONEOFFSET, _longshipHeight + DROPZONEOFFSET);
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
                if ([skNode.name hasPrefix:BOATPROWNODENAME] && ![_longshipManager mobileLongshipIsActive])
                {
                    // spawn mobile longship
                    [_longshipManager createMobileLongshipAtLocation:location withParent:self debug:YES];
                }
                else if([skNode.name hasPrefix:BOATNODENAME] && [skNode userData])
                {
                    [_longshipManager longshipDragStart:[skNode userData][USERDATAENTITYIDKEY]
                                               location:[skNode position]];
                }
            }
            break;

            case VMATouchEventTypeMoved:
            {
                if ([_longshipManager mobileLongshipIsActive])
                {
                    // update location of mobile longship
                    [_longshipManager handleLongshipMove:location withEntity:_longshipManager.mobileLongship];

                    // update drop zone highlight
                    [self handleDropZoneHighlight];
                }
                else
                {
                    // handle dragging a 'real' longship
                    [_longshipManager handleLongshipDrag:location];
                }
            }
            break;

            case VMATouchEventTypeEnded:
            {
                if ([_longshipManager mobileLongshipIsActive])
                {
                    [self handleDropZoneHighlight];
                    [self dropMobileLongship:(CGPoint)location];
                }
                else
                {
                    [self handleDropZoneHighlight];
                    [self dropLongship:(CGPoint)location];
                    [_longshipManager longshipDragStop];
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

-(void)handleDropZoneHighlight
{
    // see if drop zone needs highlighting
    VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                  forEntity:_longshipManager.mobileLongship];
    if (vrcomp)
    {
        VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
        if (CGRectIntersectsRect([rcomp getSprite].frame, _longshipDropZone))
        {
            if (!_dropZoneHighlight)
            {
                //NSLog(@"highlight ON");
                _dropZoneHighlight = [[_appDelegate entityFactory] createHighlightForRect:_longshipDropZone
                                                                               withParent:self];
                return;
            }
        }
    }

    if (_dropZoneHighlight)
    {
        //NSLog(@"highlight OFF");
        [[_appDelegate entityManager] removeEntity:_dropZoneHighlight];
        _dropZoneHighlight = nil;
    }
}

-(void)dropMobileLongship:(CGPoint)location
{
    // If mobile longship intersects drop zone, animate to there, else animate it back to shed
    CGRect mobileRect = [_longshipManager mobileLongshipFrame];
    CGPoint targetLoc1 = CGPointMake(_longshipDropZone.origin.x + (_longshipDropZone.size.width / 2),
                                     _longshipDropZone.origin.y + (_longshipDropZone.size.height / 2));
    CGPoint targetLoc2 = CGPointMake(_boatShedNode.position.x + BOATSHEDOFFSET,
                                     (_boatShedNode.position.y + (_boatShedNode.size.height / 2)));

    SKAction* appendAction = [SKAction performSelector:@selector(despawnMobileLongship) onTarget:self];

    if ([_longshipManager dropLongship:[_longshipManager mobileLongship]
                                 rect1:_longshipDropZone
                                 rect2:mobileRect
                                  drop:location
                                point1:targetLoc1
                                point2:targetLoc2
                            withAction:appendAction])
    {
        // return value of YES means longship was dropped in drop zone
        [self updateDropZoneWithIncrement:YES];

        // spawn a 'real' longship at this location
        [_longshipManager createLongshipAtLocation:targetLoc1 withParent:self debug:NO];
    }
}

-(void)dropLongship:(CGPoint)location
{
    // Make boat shed rect
    CGRect boatShedRect = _boatShedNode.frame;

    CGPoint targetLoc2 = [_longshipManager dragStart];

    CGPoint targetLoc1 = CGPointMake(_boatShedNode.position.x + BOATSHEDOFFSET,
                                     (_boatShedNode.position.y + (_boatShedNode.size.height / 2)));

    // TODO: build an action which deletes the longship entity
    SKAction* appendAction = nil;

    // If dragged longship intersects boat shed rect, animate to there, else animate it back to the drop zone
    [_longshipManager dropLongship:[_longshipManager draggedEntity]
                             rect1:boatShedRect
                             rect2:[_longshipManager draggedLongshipFrame]
                              drop:location
                            point1:targetLoc1
                            point2:targetLoc2
                        withAction:appendAction];
}

-(void)despawnMobileLongship
{
    [_longshipManager removeMobileLongship];
    [self handleDropZoneHighlight];
}

-(void)updateDropZoneWithIncrement:(BOOL)increment
{
    [self handleDropZoneHighlight];

    CGFloat delta = increment ? -_longshipHeight : _longshipHeight;
    _longshipDropZone = CGRectMake(_longshipDropZone.origin.x,
                                   _longshipDropZone.origin.y + delta - 2 * DROPZONEOFFSET,
                                   _longshipDropZone.size.width,
                                   _longshipDropZone.size.height);

}

@end
