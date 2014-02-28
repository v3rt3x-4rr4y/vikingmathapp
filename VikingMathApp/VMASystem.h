//
//  VMASystem.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VMAEntityManager;

@protocol VMAEntitySystem
- (void)update:(float)dt;
@end

@protocol VMAEntityHealthSystem <VMAEntitySystem>
-(void)doHealthStuff;
@end

@interface VMASystem : NSObject

@property (strong) VMAEntityManager* entityManager;

- (id)initWithEntityManager:(VMAEntityManager*)entityManager;

@end
