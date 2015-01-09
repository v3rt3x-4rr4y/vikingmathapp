//
//  MyScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 27/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

@import AVFoundation;
#import "VMAGroupsActivityBuildScene.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Physics.h"
#import "VMALongshipManager.h"
#import "VMADropZoneManager.h"
#import "VMAVikingPoolManager.h"
#import "VMAVikingManager.h"
#import "VMAEntityManager.h"
#import "VMAEntityFactory.h"
#import "VMAAnimatableComponent.h"
#import "VMARenderableComponent.h"
#import "VMATransformableComponent.h"
#import "VMATransformableSystem.h"
#import "VMAAnimatableSystem.h"
#import "VMARenderableSystem.h"
#import "VMAGameOverScene.h"
#import "VMAMathUtility.h"

@implementation VMAGroupsActivityBuildScene
{
    CGRect _longshipDropZone;
    CGRect _boatShedZone;
    CGRect _onPointZone;

    SKNode* _backgroundLayer;
    SKSpriteNode* _boatShedNode;
    SKSpriteNode* _boatProwNode;
    SKSpriteNode* _backgroundNode;
    SKSpriteNode* _vikingNode;
    SKSpriteNode* _onPointZoneNode;
    SKSpriteNode* _launchButton;
    SKLabelNode* _gameParamsLabelNode;
    SKAction* _exitSound;

    VMAEntity* _boatshedHighlight;
    VMALongshipManager* _longshipManager;
    VMADropZoneManager* _dropZoneManager;
    VMAVikingManager* _vikingManager;
    VMAVikingPoolManager* _poolManager;

    VMATransformableSystem* _transformableSystem;
    VMAAnimatableSystem* _animatableSystem;
    VMARenderableSystem* _renderableSystem;

    AppDelegate* _appDelegate;
    AVAudioPlayer* _bgMusicPlayer;

    BOOL _gameOver;
    int _gameParamA, _gameParamB;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt; // time elapsed since update was last called
}

#pragma mark SCENE LIFE CYCLE

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // Initialise game parameters
        _gameParamA = (int)RandomFloatRange(1, MAXDROPZONESLOTS); // Longships
        _gameParamB = (int)RandomFloatRange(2, MAXVIKINGSPERLONGSHIP); // Vikings per longship
        NSLog(@"Longships: %d, vikings per longship: %d", _gameParamA, _gameParamB);

        _gameOver = NO;
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

        // Create layer to act as parent
        _backgroundLayer = [SKNode node];
        [self addChild:_backgroundLayer];

        _transformableSystem = [[VMATransformableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _animatableSystem = [[VMAAnimatableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _renderableSystem = [[VMARenderableSystem alloc] initWithEntityManager:[_appDelegate entityManager]];
        _longshipManager = [[VMALongshipManager alloc] initWithScene:self];
        _vikingManager = [[VMAVikingManager alloc] initWithScene:self];

        // Background sprite
        self.backgroundColor = [SKColor whiteColor];
        _backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:BACKGROUND];
        _backgroundNode.anchorPoint = CGPointZero; // set anchor point to lower left corner of sprite
        _backgroundNode.position = CGPointMake(0, 0);
        [_backgroundLayer addChild:_backgroundNode];

        // Add the boat shed
        _boatShedNode = [SKSpriteNode spriteNodeWithImageNamed:BOATSHEDNODENAME];
        _boatShedNode.anchorPoint = CGPointMake(0, 0);
        _boatShedNode.position = CGPointMake(_backgroundNode.size.width - _boatShedNode.size.width - 125.0 - DROPZONEOFFSET, DROPZONEOFFSET);
        [_backgroundLayer addChild:_boatShedNode];

        // Initialise boat shed highlight
        _boatshedHighlight = [[_appDelegate entityFactory] createBoatshedHighlightMaskForRect:_boatShedNode.frame withParent:self];
        _boatShedZone = _boatShedNode.frame;

        // Add the ship prow (drag source)
        VMAEntity* boatProwEntity = [[_appDelegate entityFactory] createShipProwForShipShed:_boatShedNode withParent:self];
        VMARenderableComponent * renComp =
            (VMARenderableComponent*) [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                              forEntity:boatProwEntity];
        _boatProwNode = [renComp getSprite];

        // Initialise long ship drop zone (use a temp longship sprite for dimensions)
        SKSpriteNode* tempShip = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@0", BOATNODENAME]];
        _dropZoneManager = [[VMADropZoneManager alloc] initWithScene:self
                                                          spriteSize:CGSizeMake(tempShip.size.width, tempShip.size.height)];
        _longshipDropZone = CGRectZero;

        // Initialise viking on-point zone (invisible)
        _onPointZoneNode = [SKSpriteNode spriteNodeWithImageNamed:ONPOINTZONENODENAME];
        _onPointZoneNode.anchorPoint = CGPointMake(0.5, 0.5);
        _onPointZoneNode.position = CGPointMake(VIKINGONPOINTXPOS, VIKINGONPOINTYPOS);
        _onPointZoneNode.name = ONPOINTZONENODENAME;
        //CGSize contactSize = CGSizeMake(_onPointZoneNode.size.width, _onPointZoneNode.size.height);
        //_onPointZoneNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: contactSize];
        //_onPointZoneNode.physicsBody.dynamic = NO;
        [_backgroundLayer addChild:_onPointZoneNode];
        _onPointZone = _onPointZoneNode.frame;

        // Initialise viking pool
        CGRect poolBounds = CGRectMake(VIKINGONPOINTXPOS + 50,
                                       self.frame.origin.y + _boatShedZone.size.height + 50,
                                       self.frame.size.width - VIKINGONPOINTXPOS - 75,
                                       self.frame.size.height - _boatShedZone.size.height - 75);
        _poolManager = [[VMAVikingPoolManager alloc] initWithScene:self
                                                        numVikings: _gameParamA * _gameParamB
                                                            bounds:poolBounds
                                                           onPoint:_onPointZoneNode.position
                                                        parentNode:self];

        // Initialise launch button
        _launchButton = [SKSpriteNode spriteNodeWithImageNamed:LAUNCHBUTTONNODENAME];
        _launchButton.anchorPoint = CGPointMake(0.5, 0.5);
        _launchButton.position = CGPointMake(_backgroundNode.size.width - _launchButton.size.width / 2, LAUNCHBUTTONYPOS);
        _launchButton.name = LAUNCHBUTTONNODENAME;
        [_backgroundLayer addChild:_launchButton];

        // Initialise game parameters label
        _gameParamsLabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
        NSString* plural = _gameParamA > 1 ? @"s" : @"";
        _gameParamsLabelNode.text = [NSString stringWithFormat:@"make %d group%@ of %d !", _gameParamA, plural, _gameParamB];
        _gameParamsLabelNode.fontColor = [UIColor blackColor];
        _gameParamsLabelNode.fontSize = 32.0f;
        _gameParamsLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _gameParamsLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _gameParamsLabelNode.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height - 75);
        [_backgroundLayer addChild:_gameParamsLabelNode];

        [self handleHighlights];

        // Initialise sounds
        _exitSound = [SKAction playSoundFileNamed:@"VikingMathApp_BattleCry.wav" waitForCompletion:YES];

        // Start the BG music
        [self playBGMusic:@"VikingMathApp_BG.mp3"];
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime
{
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;

    // Check for exit conditions
    if (_gameOver)
    {
        _gameOver = NO;
        [self levelExit:[self didWin]];
    }

    [_poolManager updateVikings:_dt];

    [_transformableSystem update:currentTime];
    [_animatableSystem update:currentTime];
    [_renderableSystem update:currentTime];
}

-(BOOL)didWin
{
    BOOL retVal = NO;
    retVal = [_poolManager numVikingsInPool] < 1;
    if (retVal)
    {
        retVal = [_longshipManager numDeployedLongships] == _gameParamA;
    }
    if (retVal)
    {
        NSArray* longshipIds = [_longshipManager deployedLongshipIds];
        for (NSObject* obj in longshipIds)
        {
            unsigned int i = [(NSNumber*)obj intValue];
            if ([_longshipManager numVikingsOnboardForLongshipWithId:i] != _gameParamB)
            {
                retVal = NO;
                break;
            }
        }
    }
    return retVal;
}

-(void)levelExit:(BOOL)didWin
{
    [_bgMusicPlayer stop];
    __weak VMAGroupsActivityBuildScene* weakSelf = self;
    SKAction* launchBlock = [SKAction runBlock:^
                           {
                               [_longshipManager launchLongships];
                           }];
    SKAction* block = [SKAction runBlock:^
                       {
                           SKScene* gameOverScene = [[VMAGameOverScene alloc] initWithSize:weakSelf.size won:didWin];
                           SKTransition* reveal = [SKTransition flipHorizontalWithDuration:0.5];
                           [weakSelf.view presentScene:gameOverScene transition:reveal];
                       }];
    [self runAction:[SKAction sequence:@[[SKAction group:@[launchBlock, _exitSound]], block]]];
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
                if ([skNode.name hasPrefix:LAUNCHBUTTONNODENAME])
                {
                    _gameOver = YES;
                    NSLog(@"LAUNCH!");
                }
                else if ([touch locationInNode:self].x > VIKINGONPOINTXPOS + 10)
                {
                    [self flashOnPointZone];
                }
                else if ([skNode.name hasPrefix:BOATPROWNODENAME])
                {
                    // we clicked on the boat shed - spawn a new longship
                    VMAEntity* longship = [_longshipManager createActorAtLocation:location withParent:self debug:NO];
                    if (longship)
                    {
                        [_longshipManager actorDragStart:longship
                                                location:[skNode position]];
                    }
                }
                else if([skNode.name hasPrefix:BOATNODENAME] && [skNode userData])
                {

                    // If the longship has vikings onboard, longship cannot be moved...
                    if ([_longshipManager numVikingsOnboardForLongshipWithId:((VMAEntity*)[skNode userData][USERDATAENTITYIDKEY]).eid] < 1)
                    {
                        // ...but if longship has NO vikings on board it can be moved
                        [_longshipManager actorDragStart:[skNode userData][USERDATAENTITYIDKEY] location:[skNode position]];
                    }
                    else
                    {
                        VMAEntity* viking = [_vikingManager createActorAtLocation:location withParent:self debug:NO];
                        if (viking)
                        {
                            [_vikingManager actorDragStart:viking
                                                  location:[skNode position]];
                        }
                    }
                }
                // We detected a touch in the viking on-point location
                else if([skNode.name hasPrefix:ONPOINTZONENODENAME])
                {
                    // ...otherwise spawn a viking at the longship instead.
                    if ([[self getPoolManager] numVikingsInPool] > 0)
                    {
                        // Spawn a viking at the on-point location.
                        VMAEntity* viking = [_vikingManager createActorAtLocation:location withParent:self debug:NO];
                        if (viking)
                        {
                            [_vikingManager actorDragStart:viking
                                                  location:[skNode position]];
                        }
                    }
                }
            }
            break;

            case VMATouchEventTypeMoved:
            {
                if ([_vikingManager draggingActor])
                {
                    // update location of longship being dragged
                    [_vikingManager handleActorMove:location withEntity:_vikingManager.draggedEntity];
                }
                else if ([_longshipManager draggingActor])
                {
                    // update location of longship being dragged
                    [_longshipManager handleActorMove:location withEntity:_longshipManager.draggedEntity];

                    // update drop zone highlight
                    [self handleHighlights];
                }
            }
            break;

            case VMATouchEventTypeEnded:
            {
                if ([_longshipManager draggingActor])
                {
                    [_longshipManager actorDragStop:(CGPoint)location];
                    [self handleHighlights];
                }
                else if ([_vikingManager draggingActor])
                {
                    [_vikingManager actorDragStop:(CGPoint)location];
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

-(VMADropZoneManager*)getDropZoneManager
{
    return _dropZoneManager;
}

-(VMALongshipManager*)getLongshipManager
{
    return _longshipManager;
}

-(VMAVikingPoolManager*)getPoolManager
{
    return _poolManager;
}

-(CGRect)getBoatShedRect
{
    return _boatShedNode.frame;
}

-(CGRect)getOnPointZoneRect
{
    return _onPointZoneNode.frame;
}

-(CGRect)getBoatProwRect
{
    return _boatProwNode.frame;
}

-(void)handleHighlights
{
    VMAComponent* vrbscomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                     forEntity:_boatshedHighlight];
    if (vrbscomp)
    {
        VMARenderableComponent* rbscomp = (VMARenderableComponent*)vrbscomp;

        VMAComponent* vrcomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                  forEntity:_longshipManager.draggedEntity];
        if (vrcomp)
        {
            VMARenderableComponent* rcomp = (VMARenderableComponent*)vrcomp;
            [_dropZoneManager highlightDropzoneIntersectedByRect:[rcomp getSprite].frame];
            rbscomp.isVisible = CGRectIntersectsRect([rcomp getSprite].frame, _boatShedZone);
        }
        else
        {
            [_dropZoneManager resetAllHighlights];
            rbscomp.isVisible = NO;
        }
    }
}

-(void)flashOnPointZone
{
    if ([_onPointZoneNode hasActions])
    {
        return;
    }
    SKAction* coloriseAction = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.6f duration:0.1];
    SKAction* upscaleAction = [SKAction scaleBy:1.1 duration:0.1];
    SKAction* upScaleColoriseAction = [SKAction group:@[coloriseAction, upscaleAction]];
    SKAction* downscaleAction = [upscaleAction reversedAction];
    SKAction* decoloriseAction = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.6f duration:0.1];
    SKAction* downScaleDecoloriseAction = [SKAction group:@[decoloriseAction, downscaleAction]];
    SKAction* action = [SKAction sequence:@[upScaleColoriseAction,
                                            downScaleDecoloriseAction,
                                            upScaleColoriseAction,
                                            downScaleDecoloriseAction]];
    [_onPointZoneNode runAction:action];
}

-(void)playBGMusic:(NSString*)filename
{
    NSError* error;
    NSURL* bgMusicURL =[[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    _bgMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:bgMusicURL error:&error];
    _bgMusicPlayer.numberOfLoops = -1;
    [_bgMusicPlayer prepareToPlay];
    [_bgMusicPlayer play];
}

@end
