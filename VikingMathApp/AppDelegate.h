//
//  AppDelegate.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 27/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VMAEntityManager;
@class VMAEntityFactory;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) VMAEntityManager* entityManager;
@property (strong) VMAEntityFactory* entityFactory;

@end
