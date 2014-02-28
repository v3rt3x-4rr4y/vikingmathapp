//
//  VMAEntityFactory.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAEntityFactory.h"

@implementation VMAEntityFactory
{
    VMAEntityManager* _entityManager;
    SKNode* _parentNode;
}

- (id)initWithEntityManager:(VMAEntityManager*)entityManager parentNode:(SKNode*)parentNode
{
    if ((self = [super init]))
    {
        _entityManager = entityManager;
        _parentNode = parentNode;
    }
    return self;
}


@end
