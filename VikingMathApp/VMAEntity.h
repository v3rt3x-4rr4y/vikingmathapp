//
//  VMAEntity.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMAEntity : NSObject

- (id)initWithEntityId:(uint32_t)eid;
- (uint32_t)eid;

@end
