//
//  Physics.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#ifndef VikingMathApp_Physics_h
#define VikingMathApp_Physics_h

/*
 typedef NS_OPTIONS
 Here, we're using a "bit field" for 2 reasons:
 1.
 As an efficient way of representing something
 whose state is defined by several "yes or no" properties - in this case, we're
 using the position of the "1" in the field to tells us what category each particular
 type of physics body belongs to.
 2.
 When we test for physics body collisions, we will have to decide which bodies to collide
 with each other (and which to ignore) many times over in a short space of time, so it makes
 sense to make process as efficient as possible. Storing physics body categories in a bit field
 allows us to do this is with bitwise logic operations, which are very fast (compared to, say,
 looping through lists, etc).
 */
typedef NS_OPTIONS(uint32_t, VMAPhysicsCategory)
{
    VMAPhysicsCategoryLongship = 1 << 0, // 0001 = 1
    VMAPhysicsCategoryViking = 1 << 1, // 0010 = 2
    VMAPhysicsCategoryOnPointZone = 1 << 2, // 0100 = 4
};

static const float TRANSLATE_VELOCITY_PIXELS_PER_SEC = 2500;
static const NSTimeInterval DESPAWN_DELAY = 0.05;

#endif
