//
//  VMAEntityFactory.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKNode;
@class VMAEntityManager;

@interface VMAEntityFactory : NSObject

- (id)initWithEntityManager:(VMAEntityManager *)entityManager parentNode:(SKNode*)parentNode;

@end
