//
//  VMAGameOverScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 24/06/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMAGameOverScene.h"
#import "VMAMainMenuScene.h"

@implementation VMAGameOverScene
{
    SKAction* _loseSound;
    SKAction* _winSound;
}

-(id)initWithSize:(CGSize)size won:(BOOL)didWin
{
    if (self = [super initWithSize:size])
    {
        _loseSound = [SKAction playSoundFileNamed:@"VikingMathApp_Aww.wav" waitForCompletion:NO];
        _winSound = [SKAction playSoundFileNamed:@"VikingMathApp_Win.wav" waitForCompletion:NO];
        SKSpriteNode *bg;
        if (didWin)
        {
            bg = [SKSpriteNode spriteNodeWithImageNamed:@"WinScreen_Background"];
            [self runAction:[SKAction sequence:@[_winSound, [SKAction waitForDuration:0.1]]]];
        }
        else
        {
            bg = [SKSpriteNode spriteNodeWithImageNamed:@"LoseScreen_Background"];
            [self runAction:[SKAction sequence:@[_loseSound, [SKAction waitForDuration:0.1]]]];
        }

        bg.position = CGPointMake(self.size.width/2, self.size.height/2); [self addChild:bg];

        SKAction* wait = [SKAction waitForDuration:3.0];
        SKAction* block = [SKAction runBlock:^
                           {
                               VMAMainMenuScene* mainMenuScene = [[VMAMainMenuScene alloc] initWithSize:self.size];
                               SKTransition* reveal = [SKTransition flipHorizontalWithDuration:0.5];
                               [self.view presentScene:mainMenuScene transition:reveal];
                           }];
        [self runAction:[SKAction sequence:@[wait, block]]];
    }
    return self;
}

@end
