//
//  VMAMainMenuScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAMainMenuScene.h"
#import "VMAGroupsActivityBuildScene.h"

@implementation VMAMainMenuScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        SKSpriteNode *bg;
        bg = [SKSpriteNode spriteNodeWithImageNamed:@"LandingScreen_Background"];
        bg.position = CGPointMake(self.size.width / 2, self.size.height / 2); [self addChild:bg];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    __weak VMAMainMenuScene* weakSelf = self;
    SKAction* block = [SKAction runBlock:^
                      {
                          VMAGroupsActivityBuildScene* myScene = [[VMAGroupsActivityBuildScene alloc] initWithSize:weakSelf.size];
                          SKTransition* reveal = [SKTransition doorsOpenHorizontalWithDuration:0.5];
                          [weakSelf.view presentScene:myScene transition:reveal];
                      }];
    [self runAction:block];
}

@end
