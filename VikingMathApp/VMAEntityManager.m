//
//  VMAEntityManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "VMAEntityManager.h"

@implementation VMAEntityManager
{
    NSMutableArray * _entities;
    NSMutableDictionary * _componentsByClass;
    uint32_t _lowestUnassignedEid;
}

- (id)init
{
    if ((self = [super init]))
    {
        /// array of entities
        _entities = [NSMutableArray array];
        /// map of components keyed by component type
        _componentsByClass = [NSMutableDictionary dictionary];
        /// tracks currently assigned entity IDs
        _lowestUnassignedEid = 1;
    }
    return self;
}

- (uint32_t)generateNewEntityId
{
    if (_lowestUnassignedEid < UINT32_MAX)
    {
        uint32_t retVal = _lowestUnassignedEid++;
        //NSLog(@"Generated id: %d", retVal);
        return retVal;
    }
    else
    {
        for (uint32_t i = 1; i < UINT32_MAX; ++i)
        {
            if (![_entities containsObject:@(i)])
            {
                return i;
            }
        }
        NSLog(@"ERROR: No available EIDs!");
        return 0;
    }
}

- (VMAEntity *)createEntity
{
    uint32_t eid = [self generateNewEntityId];
    [_entities addObject:@(eid)];
    return [[VMAEntity alloc] initWithEntityId:eid];
}

- (void)addComponent:(VMAComponent *)component toEntity:(VMAEntity *)entity
{
    // from the dictionary which keys component class names to a dictionary of entity IDs keyed
    // to component objects, get the dictionary for the supplied component object's class
    NSMutableDictionary * components = _componentsByClass[NSStringFromClass([component class])];
    // or create it if it doesn't yet exist
    if (!components)
    {
        components = [NSMutableDictionary dictionary];
        _componentsByClass[NSStringFromClass([component class])] = components;
    }
    // now map the supplied component to the supplied entity ID
    components[@(entity.eid)] = component;
}

- (VMAComponent *)getComponentOfClass:(Class)class forEntity:(VMAEntity *)entity
{
    return _componentsByClass[NSStringFromClass(class)][@(entity.eid)];
}

-(NSArray*)getAllComponentsOfClass:(Class)class
{
    return [_componentsByClass[NSStringFromClass(class)] allValues];
}

- (void)removeEntity:(VMAEntity *)entity
{
    /// remove all components from the specified entity...
    for (NSMutableDictionary * components in _componentsByClass.allValues)
    {
        if (components[@(entity.eid)])
        {
            VMAComponent* comp = [components objectForKey:@(entity.eid)];
            [comp tearDown];
            [components removeObjectForKey:@(entity.eid)];
        }
    }
    /// ... then remove the entity itself
    [_entities removeObject:@(entity.eid)];
}

- (NSArray *)getAllEntitiesPosessingComponentOfClass:(Class)class
{
    NSMutableDictionary * components = _componentsByClass[NSStringFromClass(class)];
    if (components)
    {
        NSMutableArray * retval = [NSMutableArray arrayWithCapacity:components.allKeys.count];
        for (NSNumber * eid in components.allKeys)
        {
            [retval addObject:[[VMAEntity alloc] initWithEntityId:eid.unsignedIntValue]];
        }
        return retval;
    }
    else
    {
        return [NSArray array];
    }
}

- (NSArray *)getAllEntitiesPosessingComponentOfClass:(Class)class fromArray:(NSArray*)array;
{
    NSMutableDictionary * components = _componentsByClass[NSStringFromClass(class)];
    if (components)
    {
        __block NSMutableArray * retval = [NSMutableArray arrayWithCapacity:components.allKeys.count];
        for (NSNumber * eid in components.allKeys)
        {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                SKNode* skNode = (SKNode*)obj;
                if ([skNode.name isEqualToString:[NSString stringWithFormat:@"%d", [eid intValue]]])
                 {
                     [retval addObject:[[VMAEntity alloc] initWithEntityId:eid.unsignedIntValue]];
                     *stop = YES;
                 }
             }];
        }
        return retval;
    }
    else
    {
        return [NSArray array];
    }
}
@end
