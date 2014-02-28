//
//  VMAEntity.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAEntity.h"

@implementation VMAEntity
{
    uint32_t _eid;
}

- (id)initWithEntityId:(uint32_t)eid
{
    if ((self = [super init]))
    {
        _eid = eid;
    }
    return self;
}

- (uint32_t)eid
{
    return _eid;
}

@end
