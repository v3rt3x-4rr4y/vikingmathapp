//
//  VMAComponent.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VMAComponent
- (void)tearDown;
@end

@interface VMAComponent : NSObject <VMAComponent>

@end
