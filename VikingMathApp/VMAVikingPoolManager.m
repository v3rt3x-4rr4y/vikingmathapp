//
//  VMAVikingPoolManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 23/06/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAVikingPoolManager.h"
#import "VMAEntityFactory.h"
#import "VMAEntityManager.h"
#import "VMAComponent.h"
#import "VMATransformableComponent.h"
#import "VMAAnimatableComponent.h"
#import "VMARenderableComponent.h"
#import "VMAMathUtility.h"
#import "AppDelegate.h"
#import "VMAEntity.h"
#import "Constants.h"
#import "Physics.h"

@implementation VMAVikingPoolManager
{
    SKNode* _parentNode;
    SKAction* _vikingWalkCycle;
    VMAGroupsActivityBuildScene* _scene;
    VMAEntity* _onPointViking;
    NSMutableArray* _vikings;
    AppDelegate* _appDelegate;
    CGRect _poolBounds;
    CGPoint _onPointLocation;
    BOOL _actionsCompleted;
    int _maxVikings;
}

-(instancetype)initWithScene:(SKScene*)invokingScene
                  numVikings:(int)vikings
                      bounds:(CGRect)poolBounds
                     onPoint:(CGPoint)location
                  parentNode:(SKNode*)parent;
{
    if (self = [super init])
    {
        _scene = (VMAGroupsActivityBuildScene*)invokingScene;
        _vikings = [NSMutableArray arrayWithCapacity:vikings];
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _actionsCompleted = YES;
        _maxVikings = vikings;
        _poolBounds = poolBounds;
        _onPointLocation = location;
        _parentNode = parent;
        _onPointViking = nil;

        // instantiate the main viking walk cycle animation
        NSMutableArray* textures = [NSMutableArray arrayWithCapacity:10];
        for (int i = 1; i <= 3; i++)
        {
            NSString* textureName = [NSString stringWithFormat:@"%@_%d", VIKINGNODENAME, i];
            SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        for (int i = 3; i >= 1 ; i--)
        {
            NSString* textureName = [NSString stringWithFormat:@"%@_%d", VIKINGNODENAME, i];
            SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        for (int i = 4; i <= 5; i++)
        {
            NSString* textureName = [NSString stringWithFormat:@"%@_%d", VIKINGNODENAME, i];
            SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        for (int i = 5; i >= 4 ; i--)
        {
            NSString* textureName = [NSString stringWithFormat:@"%@_%d", VIKINGNODENAME, i];
            SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }

        _vikingWalkCycle = [SKAction animateWithTextures:textures timePerFrame:0.1];

        // Call addVikingToPool "_maxVikings" times
        for (int i = 0; i < _maxVikings; i++)
        {
            [self addVikingToPoolAtLocation:CGPointZero];
        }

        // Move one viking from the line-up to the on point location
        //[self advanceVikingToOnPoint];

        // Layout the vikings
        [self layoutVikings:TRUE];
    }
    return self;
}

-(void)addVikingToPoolAtLocation:(CGPoint)location;
{
    BOOL empty = [_vikings count] < 1;
    if (CGPointEqualToPoint(location, CGPointZero))
    {
        location = [self makeRandomPoolCoords];
    }

    // Create a new entity
    VMAEntity* viking = [[_appDelegate entityFactory] createVikingAtLocation:location
                                                                  withParent:_parentNode
                                                                        name:@""
                                                                       debug:NO];

    VMATransformableComponent* tcomp = (VMATransformableComponent*)[[_appDelegate entityManager]
                                                                    getComponentOfClass:[VMATransformableComponent class]
                                                                    forEntity:viking];

    tcomp.rotation = DegreesToRadians(RandomFloatRange(0.0f, 359.0f));
    tcomp.xformVectorNormalised = CGPointNormalize(CGPointMake(cosf(tcomp.rotation),
                                                               sinf(tcomp.rotation)));

    [self setAction:[SKAction repeatActionForever:_vikingWalkCycle]
           forActor:viking withBlockingMode:NO
             forkey:@""];

    // Push it onto the end of collection ([Array addObject])
    [_vikings addObject:viking];
    _onPointViking = [_vikings firstObject];

    if (empty)
    {
        [self advanceVikingToOnPoint];
    }
}

-(void)removeVikingFromPool
{
    if (!_onPointViking)
    {
        NSLog(@"No vikings left to remove");
        return;
    }

    NSLog(@"Removed viking from pool with id: %d", [_onPointViking eid]);

    // Pop the last viking to be added from the collection
    [_vikings removeObject:_onPointViking];

    // Despawn and delete the viking that is currently on-point
    [[_appDelegate entityManager] removeEntity:_onPointViking];

    _onPointViking = [_vikings firstObject];
}

-(void)advanceVikingToOnPoint
{
    // Get a reference to the first viking to be added from the collection
    if (!_onPointViking)
    {
        NSLog(@"No vikings left in pool!");
        return;
    }

    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                   forEntity:_onPointViking];
    if (vacomp)
    {
        VMARenderableComponent* acomp = (VMARenderableComponent*)vacomp;
        [[acomp getSprite] removeAllActions];

        // Reset the texture, as cancelling walk cycle may leave sprite in mid-cycle
        [[acomp getSprite] setTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@_1", VIKINGNODENAME]]];
    }

    // Animate this viking from the line-up to the on-point position
    VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                   forEntity:_onPointViking];
    if (vtcomp)
    {
        VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
        [self animateViking:_onPointViking
               FromLocation:[tcomp location]
                 toLocation:CGPointMake(VIKINGONPOINTXPOS, VIKINGONPOINTYPOS)
                   withAction:[SKAction rotateToAngle:DegreesToRadians(90.0f) duration:0.4f]];
    }
    NSLog(@"Viking on point will be: %d", [_onPointViking eid]);
}

-(void)animateViking:(VMAEntity*)entity
        FromLocation:(CGPoint)dropPoint
          toLocation:(CGPoint)targetPoint
            withAction:(SKAction*)action
{
    // determine action velocity based on distance
    double distance = sqrt(pow((targetPoint.x - dropPoint.x), 2.0) + pow((targetPoint.y - dropPoint.y), 2.0));

    // build move and despawn actions
    SKAction* moveAction = [SKAction moveTo:targetPoint duration:distance / TRANSLATE_VELOCITY_PIXELS_PER_SEC_SLOW];
    moveAction.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* compositeAction = action ? [SKAction group:@[moveAction, action]] : moveAction;

    // animate the viking to its destination and despawn
    [self setAction:compositeAction forActor:entity withBlockingMode:YES forkey:@""];
}

-(void)layoutVikings:(BOOL)randomise
{
    // Loop through all vikings and update their positions centred around the centre of the pool rect.
    int index = 0;
    int baseOffset = [_vikings count] * VIKINGSPRITEHEIGHT * 0.5;
    for (VMAEntity* viking in _vikings)
    {
        if ([viking isEqual:_onPointViking])
        {
            NSLog(@"Viking on point is: %d, %d", [viking eid], [_onPointViking eid]);
            continue;
        }

        // Get xformable component
        VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                       forEntity:viking];
        if (vtcomp)
        {
            float offset = (index * VIKINGSPRITEHEIGHT) + VIKINGSPRITEHEIGHT;
            CGFloat x;
            CGFloat y;
            CGPoint location;
            CGFloat rotation;
            if (!randomise)
            {
                x = _poolBounds.origin.x + _poolBounds.size.width * 0.5,
                y = (_poolBounds.origin.y + _poolBounds.size.height * 0.5) - baseOffset + offset;
                location = CGPointMake(x, y);
                rotation = 0.0f;
            }
            else
            {
                location = [self makeRandomPoolCoords];
                rotation = DegreesToRadians(RandomFloatRange(0.0f, 359.0f));
            }

            VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
            [tcomp setLocation:location];
            [tcomp setRotation:rotation];
            [tcomp setXformVectorNormalised:CGPointNormalize(CGPointMake(cosf(tcomp.rotation),
                                                                         sinf(tcomp.rotation)))];
        }
        index++;
    }
}

-(CGPoint)makeRandomPoolCoords
{
    CGFloat x = _poolBounds.origin.x + RandomFloatRange(VIKINGSPRITEHEIGHT, _poolBounds.size.width - VIKINGSPRITEHEIGHT);
    CGFloat y = _poolBounds.origin.y + RandomFloatRange(VIKINGSPRITEHEIGHT, _poolBounds.size.height - VIKINGSPRITEHEIGHT);
    return CGPointMake(x, y);
}

-(NSUInteger)numVikingsInPool
{
    return [_vikings count];
}

-(void)updateVikings:(NSTimeInterval)elapsedTime;
{
    // NB: pool rect = _poolBounds

    // Loop through all vikings, update location, rotation and animation
    for (VMAEntity* viking in _vikings)
    {
        // ignore the on-point viking
        if ([viking isEqual:_onPointViking])
        {
            continue;
        }

        // Get xformable component
        VMATransformableComponent* tcomp = (VMATransformableComponent*)[[_appDelegate entityManager]
                                                                        getComponentOfClass:[VMATransformableComponent class]
                                                                        forEntity:viking];

        // Check for boundary infringements
        CGPoint loc = [tcomp location];
        CGPoint xformVector = tcomp.xformVectorNormalised;
        [self vikingBoundsCheck:&loc xformVector:&xformVector];

        CGPoint xformVectorThisFrame = CGPointMultiplyScalar(xformVector, VIKING_MOVE_POINTS_PER_SEC * elapsedTime);

        // update the location
        tcomp.location = CGPointAdd(tcomp.location, xformVectorThisFrame);

        CGFloat result = atan2f(xformVectorThisFrame.y, xformVectorThisFrame.x);
        CGFloat least = ScalarShortestAngleBetween(tcomp.rotation + DegreesToRadians(90.0f), result);
        CGFloat rotAmount = (VIKING_ROTATE_RADIANS_PER_SEC * elapsedTime);
        rotAmount = (fabsf(least) < fabsf(rotAmount) ? fabsf(least):fabsf(rotAmount));
        rotAmount *= ScalarSign(least);

        // update the rotation
        tcomp.rotation += rotAmount;

        // update the xform vector
        tcomp.xformVectorNormalised = xformVector;
    }
}

- (void)vikingBoundsCheck:(CGPoint*)position xformVector:(CGPoint*)xformVector
{

    // find the screen bounds
    CGPoint bottomLeft = _poolBounds.origin;
    CGPoint topRight = CGPointMake(_poolBounds.origin.x + _poolBounds.size.width, _poolBounds.origin.y + _poolBounds.size.height);

    // check whether zombie has strayed beyond screen bounds, if so bounce off at 90 degrees
    if (position->x <= bottomLeft.x)
    {
        position->x = bottomLeft.x;
        xformVector->x = -xformVector->x;
    }
    if (position->x >= topRight.x)
    {
        position->x = topRight.x;
        xformVector->x = -xformVector->x;
    }
    if (position->y <= bottomLeft.y)
    {
        position->y = bottomLeft.y;
        xformVector->y = -xformVector->y;
    }
    if (position->y >= topRight.y)
    {
        position->y = topRight.y;
        xformVector->y = -xformVector->y;
    }
}

-(void)setAction:(SKAction*)action forActor:(VMAEntity*)actor withBlockingMode:(BOOL)blockMode forkey:(NSString*)key
{
    VMAComponent* vacomp = [[_appDelegate entityManager] getComponentOfClass:[VMAAnimatableComponent class]
                                                                   forEntity:actor];
    if (vacomp)
    {
        VMAAnimatableComponent* acomp = (VMAAnimatableComponent*)vacomp;
        [acomp setAction:action withBlockingMode:blockMode forkey:key];
    }
}

@end
