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

@implementation VMAVikingPoolManager
{
    SKNode* _parentNode;
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

        // Call addVikingToPool "_maxVikings" times
        for (int i = 0; i < _maxVikings; i++)
        {
            [self addVikingToPool];
        }

        // Move one viking from the line-up to the on point location
        //[self advanceVikingToOnPoint];

        // Layout the vikings
        [self layoutVikings:TRUE];
    }
    return self;
}

-(void)addVikingToPool
{
    BOOL empty = [_vikings count] < 1;
    CGPoint location = [self makeRandomCoords];

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

    SKAction* wiggleAction = [SKAction rotateByAngle:DegreesToRadians(10.0f) duration:0.1];
    SKAction* revWiggleAction = [wiggleAction reversedAction];
    [self setAction:[SKAction repeatActionForever:[SKAction sequence:@[wiggleAction, revWiggleAction]]]
           forActor:viking withBlockingMode:NO
             forkey:@""];

    // Push it onto the end of collection ([Array addObject])
    [_vikings addObject:viking];

    if (empty)
    {
        [self advanceVikingToOnPoint];
    }
}

-(void)removeVikingFromPool
{
    VMAEntity* viking = [_vikings lastObject];
    if (!viking)
    {
        NSLog(@"No vikings left to remove");
        return;
    }
    NSLog(@"Removed viking from pool with id: %d", [viking eid]);

    // Pop the last viking to be added from the collection
    [_vikings removeObject:viking];

    // Despawn and delete the viking that is currently on-point
    [[_appDelegate entityManager] removeEntity:viking];
}

-(void)advanceVikingToOnPoint
{
    // Get a reference to the last viking to be added from the collection ([Array lastObject]).
    VMAEntity* viking = [_vikings firstObject];
    if (!viking)
    {
        NSLog(@"No vikings left in pool!");
        return;
    }

    // Animate this viking from the line-up to the on-point position
    VMAComponent* vtcomp = [[_appDelegate entityManager] getComponentOfClass:[VMATransformableComponent class]
                                                                   forEntity:viking];
    if (vtcomp)
    {
        VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
        [tcomp setLocation:CGPointMake(VIKINGONPOINTXPOS, VIKINGONPOINTYPOS)];
        [tcomp setRotation:DegreesToRadians(90.0f)];
    }
    [self setAction:nil forActor:viking withBlockingMode:NO forkey:@""];

    NSLog(@"Viking on point will be: %d", [viking eid]);

    _onPointViking = viking;
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
                location = [self makeRandomCoords];
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

-(CGPoint)makeRandomCoords
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
        //NSLog(@"move vector this frame: %f, %f",xformVectorThisFrame.x, xformVectorThisFrame.y);
        //NSLog(@"rotation this frame: %f", RadiansToDegrees(tcomp.rotation));

        // update the location
        tcomp.location = CGPointAdd(tcomp.location, xformVectorThisFrame);

        CGFloat result = atan2f(xformVectorThisFrame.y, xformVectorThisFrame.x);
        //NSLog(@"result: %f", result);
        //NSLog(@"xformVector.x: %f, xformVector.y: %f ", xformVectorThisFrame.x, xformVectorThisFrame.y);
        CGFloat least = ScalarShortestAngleBetween(tcomp.rotation + DegreesToRadians(90.0f), result);
        CGFloat rotAmount = (VIKING_ROTATE_RADIANS_PER_SEC * elapsedTime);
        rotAmount = (fabsf(least) < fabsf(rotAmount) ? fabsf(least):fabsf(rotAmount));
        rotAmount *= ScalarSign(least);
        //NSLog(@"rotAmount: %f", RadiansToDegrees(rotAmount));
        //NSLog(@"Before: %f", RadiansToDegrees(tcomp.rotation));
        //NSLog(@"After: %f", RadiansToDegrees(tcomp.rotation));

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
