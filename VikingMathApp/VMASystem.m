//
//  VMASystem.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMASystem.h"

@implementation VMASystem

- (id)initWithEntityManager:(VMAEntityManager *)entityManager
{
    if ((self = [super init]))
    {
        self.entityManager = entityManager;
    }
    return self;
}

@end
