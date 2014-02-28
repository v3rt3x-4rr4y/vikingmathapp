//
//  VMAMathUtility.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <GLKit/GLKMath.h>

static const unsigned int ARC4RANDOM_MAX = 0xFFFFFFFF;

static __inline__ float DegreesToRadians(const float d)
{
    return (M_PI * (d) / 180.0f);
}
static __inline__ float RadiansToDegrees(const float r)
{
    return ((r) * 180.0f / M_PI);
}

static __inline__ CGPoint CGPointFromGLKVector2(GLKVector2 vector)
{
    return CGPointMake(vector.x, vector.y);
}

static __inline__ GLKVector2 GLKVector2FromCGPoint(CGPoint point)
{
    return GLKVector2Make(point.x, point.y);
}

static __inline__ CGPoint CGPointAdd(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

static __inline__ CGPoint CGPointSubtract(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

static __inline__ CGPoint CGPointMultiply(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x * point2.x, point1.y * point2.y);
}

static __inline__ CGPoint CGPointDivide(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x / point2.x, point1.y / point2.y);
}

static __inline__ CGPoint CGPointMultiplyScalar(CGPoint point, CGFloat value)
{
    return CGPointFromGLKVector2(GLKVector2MultiplyScalar(GLKVector2FromCGPoint(point), value));
}

static __inline__ CGFloat CGPointLength(CGPoint point)
{
    return GLKVector2Length(GLKVector2FromCGPoint(point));
}

static __inline__ CGPoint CGPointNormalize(CGPoint point)
{
    return CGPointFromGLKVector2(GLKVector2Normalize(GLKVector2FromCGPoint(point)));
}

static __inline__ CGFloat CGPointDistance(CGPoint point1, CGPoint point2)
{
	return CGPointLength(CGPointSubtract(point1, point2));
}

/*
 Calculates angle formed by a vector:

    /|
 h / |y
  /a |
  ---
   x

 a = atan(y/x)

 */
static __inline__ CGFloat CGPointToAngle(CGPoint point)
{
    return atan2f(point.y, point.x);
}

static __inline__ CGPoint CGPointForAngle(CGFloat value)
{
    return CGPointMake(cosf(value), sinf(value));
}

static __inline__ CGPoint CGPointLerp(CGPoint startPoint, CGPoint endPoint, float t)
{
    return CGPointMake(startPoint.x + (endPoint.x - startPoint.x) * t,
                       startPoint.y + (endPoint.y - startPoint.y) * t);
}

// Returns 1 or -1 depending on whether arg is < or > zero.
static __inline__ CGFloat ScalarSign(CGFloat value)
{
    return value >= 0 ? 1 : -1;
}

/**
 Returns smallest angle between two angles, between -M_PI and M_PI.
 Used to determine direction
 and maginutude of angle when rotating sprite to face a point.
 */
static __inline__ CGFloat ScalarShortestAngleBetween(CGFloat value1, CGFloat value2)
{
    CGFloat difference = value2 - value1;
    CGFloat angle = fmodf(difference, M_PI * 2);
    if (angle >= M_PI)
    {
        angle -= M_PI * 2;
    }
    if (angle <= -M_PI)
    {
        angle += M_PI * 2;
    }
    return angle;
}

static __inline__ CGFloat RandomFloat(void)
{
    return (CGFloat)arc4random()/ARC4RANDOM_MAX;
}

static __inline__ CGFloat RandomFloatRange(CGFloat min, CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

static __inline__ CGFloat RandomSign(void)
{
	return arc4random_uniform(2) == 0 ? 1.0f : -1.0f;
}

static __inline__ CGFloat Clamp(CGFloat value, CGFloat min, CGFloat max)
{
    return value < min ? min : value > max ? max : value;
}
