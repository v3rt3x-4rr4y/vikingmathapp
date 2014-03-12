//
//  VMADropZone.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 12/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMAEntity.h"

@interface VMADropZone : NSObject

@property (assign) int index;
@property (assign) BOOL occupied;
@property (assign) CGRect rect;
@property (strong) VMAEntity* entity;

@end
