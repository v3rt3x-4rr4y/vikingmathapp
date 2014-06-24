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
#import "VMAMathUtility.h"
#import "AppDelegate.h"
#import "VMAEntity.h"
#import "Constants.h"

@implementation VMAVikingPoolManager
{
    NSMutableArray* _vikings;
    AppDelegate* _appDelegate;
    VMAGroupsActivityBuildScene* _scene;
    BOOL _actionsCompleted;
    int _maxVikings;
    CGRect _poolBounds;
    CGPoint _onPointLocation;
    SKNode* _parentNode;
    VMAEntity* _onPointViking;
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
        [self advanceVikingToOnPoint];

        // Layout the vikings
        [self layoutVikings:TRUE];
    }
    return self;
}

-(void)addVikingToPool
{
    BOOL empty = [_vikings count] < 1;
    // Initial position is the centre of the pool
    CGPoint location = [self makeRandomCoords];

    // Create a new entity
    VMAEntity* viking = [[_appDelegate entityFactory] createVikingAtLocation:location
                                                                  withParent:_parentNode
                                                                        name:@""
                                                                       debug:NO];

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
    }
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
            if (!randomise)
            {
                x = _poolBounds.origin.x + _poolBounds.size.width * 0.5,
                y = (_poolBounds.origin.y + _poolBounds.size.height * 0.5) - baseOffset + offset;
                location = CGPointMake(x, y);
            }
            else
            {
                location = [self makeRandomCoords];
            }

            VMATransformableComponent* tcomp = (VMATransformableComponent*)vtcomp;
            [tcomp setLocation:location];
        }
        index++;
    }
}

-(CGPoint)makeRandomCoords
{
    CGFloat x = _poolBounds.origin.x + RandomFloatRange(VIKINGSPRITEHEIGHT, _poolBounds.size.width - VIKINGSPRITEHEIGHT);
    CGFloat y = _poolBounds.origin.y + [_scene getBoatShedRect].size.height +
    RandomFloatRange(VIKINGSPRITEHEIGHT, _poolBounds.size.height -
                     [_scene getBoatShedRect].size.height -
                     VIKINGSPRITEHEIGHT);
    return CGPointMake(x, y);
}

-(int)numVikingsInPool
{
    return [_vikings count];
}

@end
