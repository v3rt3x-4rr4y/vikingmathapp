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
#import "VMARenderableSystem.h"

@implementation VMAGroupsActivityBuildScene
{
    CGRect _longshipDropZone;
    CGRect _boatShedZone;
    CGFloat _longshipHeight;

    SKNode* _backgroundLayer;
    SKSpriteNode* _boatShedNode;
    SKSpriteNode* _boatProwNode;
    SKSpriteNode* _backgroundNode;

    VMAEntity* _dropZoneHighlight;
    VMAEntity* _boatshedHighlight;
    VMALongshipManager* _longshipManager;

    VMATransformableSystem* _transformableSystem;
    VMAAnimatableSystem* _animatableSystem;
    VMARenderableSystem* _renderableSystem;

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

        _transformableSystem = [[VMATransformableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _animatableSystem = [[VMAAnimatableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _renderableSystem = [[VMARenderableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _longshipManager = [[VMALongshipManager alloc] initWithScene:self];

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

        // Initialise boat shed highlight
        _boatshedHighlight = [[_appDelegate entityFactory] createBoatshedHighlightMaskForRect:_boatShedNode.frame withParent:self];
        _boatShedZone = _boatShedNode.frame;

        // Add the ship prow (drag source)
        VMAEntity* boatProwEntity = [[_appDelegate entityFactory] createShipProwForShipShed:_boatShedNode withParent:self];
        //_boatProwNode =
        VMARenderableComponent * renComp =
            (VMARenderableComponent*) [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                              forEntity:boatProwEntity];
        _boatProwNode = [renComp getSprite];

        // Initialise long ship drop zone (use a temp longship sprite for dimensions)
        SKSpriteNode* tempShip = [SKSpriteNode spriteNodeWithImageNamed:BOATNODENAME];
        _longshipHeight = tempShip.size.height;
        _longshipDropZone = CGRectMake(DROPZONEOFFSET, _backgroundNode.size.height - _longshipHeight - 2 * DROPZONEOFFSET,
                                       tempShip.size.width + DROPZONEOFFSET, _longshipHeight + DROPZONEOFFSET);

        // Initialise drop zone highlight entity (invisible initially)
        _dropZoneHighlight = [[_appDelegate entityFactory] createDropzoneHighlightMaskForRect:_longshipDropZone withParent:self];
        [self handleHighlights];
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime
{
    [_transformableSystem update:currentTime];
    [_animatableSystem update:currentTime];
    [_renderableSystem update:currentTime];
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
                if ([skNode.name hasPrefix:BOATPROWNODENAME])
                {
                    // spawn a new longship
                    VMAEntity* longship = [_longshipManager createLongshipAtLocation:location withParent:self debug:NO];
                    if (longship)
                    {
                        [_longshipManager longshipDragStart:longship
                                                   location:[skNode position]];
                    }
                }
                else if([skNode.name hasPrefix:BOATNODENAME] && [skNode userData])
                {
                    // we clicked on an existing longship
                    [_longshipManager longshipDragStart:[skNode userData][USERDATAENTITYIDKEY] location:[skNode position]];
                }
            }
            break;

            case VMATouchEventTypeMoved:
            {
                if ([_longshipManager draggingLongship])
                {
                    // update location of longship being dragged
                    [_longshipManager handleLongshipMove:location withEntity:_longshipManager.draggedEntity];

                    // update drop zone highlight
                    [self handleHighlights];
                }
            }
            break;

            case VMATouchEventTypeEnded:
            {
                [_longshipManager longshipDragStop:(CGPoint)location];
                [self handleHighlights];
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

-(CGRect)getDropZoneRect
{
    return _longshipDropZone;
}

-(CGRect)getBoatShedRect
{
    return _boatShedNode.frame;
}

-(CGRect)getBoatProwRect
{
    return _boatProwNode.frame;
}

-(void)handleHighlights
{
    // see if drop zone or boat shed needs highlighting
    VMAComponent* vrdzcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                     forEntity:_dropZoneHighlight];
    VMAComponent* vrbscomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                     forEntity:_boatshedHighlight];

    if ((vrdzcomp) && (vrbscomp))
    {
        VMARenderableComponent* rdzcomp = (VMARenderableComponent*)vrdzcomp;
        VMARenderableComponent* rbscomp = (VMARenderableComponent*)vrbscomp;

        VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                  forEntity:_longshipManager.draggedEntity];
        if ((vrcomp) && [_longshipManager draggingLongship])
        {
            VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
            rdzcomp.isVisible = CGRectIntersectsRect([rcomp getSprite].frame, _longshipDropZone);
            rbscomp.isVisible = CGRectIntersectsRect([rcomp getSprite].frame, _boatShedZone);
        }
        else
        {
            rdzcomp.isVisible = NO;
            rbscomp.isVisible = NO;
        }
    }
}

-(void)updateDropZoneWithIncrement:(BOOL)increment
{
    [self handleHighlights];

    CGFloat delta = increment ? -_longshipHeight : _longshipHeight;
    _longshipDropZone = CGRectMake(_longshipDropZone.origin.x,
                                   _longshipDropZone.origin.y + delta - 2 * DROPZONEOFFSET,
                                   _longshipDropZone.size.width,
                                   _longshipDropZone.size.height);

}

@end
