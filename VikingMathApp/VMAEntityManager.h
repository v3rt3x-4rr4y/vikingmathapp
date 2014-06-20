//
//  VMAEntityManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMAEntity.h"
#import "VMAComponent.h"

@interface VMAEntityManager : NSObject

/** Generates a new entity ID
 @return the new entity ID, or zero.
 */
- (uint32_t) generateNewEntityId;

/** Generates a new entity object
 @return the new entity object.
 */
-(VMAEntity*)createEntity;

/** Equip the supplied entity with the supplied component.
 @param component the component to equip the entity with
 @param entity the entity to be equipped.
 @return void
 */
- (void)addComponent:(VMAComponent *)component toEntity:(VMAEntity*)entity;

/** Get the component object with the specified class from the specified entity
 @param class the class of the required component object
 @param entity the entity to retrieve the component object from
 @return the requested Component object.
 */
- (VMAComponent *)getComponentOfClass:(Class)class forEntity:(VMAEntity*)entity;

- (VMAComponent *)getComponentOfClass:(Class)class forEntityWithId:(uint32_t)entityId;

/** Get a collection of all component objects of the specified class
 @param class the class of the required component object
 @return the requested collection.
 */
-(NSArray*)getAllComponentsOfClass:(Class)class;

/** Remove the specified entity.
 @param entity the entity to retrieve the component object from
 @return void
 */
- (void)removeEntity:(VMAEntity*)entity;

/** Get an array of entities which all have a component of the specified class
 @param class the class to retrieve entities for
 @return the array of entities
 */
- (NSArray*)getAllEntitiesPosessingComponentOfClass:(Class)class;

/** Get an array of entities from the supplied set which all have a component of
 the specified class.
 @param class the class to retrieve entities for
 @param set the set to retrieve the entities from
 @return the array of entities
 */
- (NSArray *)getAllEntitiesPosessingComponentOfClass:(Class)class fromArray:(NSArray*)array;

@end
