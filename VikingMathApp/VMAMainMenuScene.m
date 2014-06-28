//
//  VMAMainMenuScene.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 28/02/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

@import AVFoundation;
#import "VMAMainMenuScene.h"
#import "VMAGroupsActivityBuildScene.h"

@implementation VMAMainMenuScene
{
    AVAudioPlayer* _bgMusicPlayer;
    SKAction* _fanfareSound;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        SKSpriteNode *bg;
        bg = [SKSpriteNode spriteNodeWithImageNamed:@"LandingScreen_Background"];
        bg.position = CGPointMake(self.size.width / 2, self.size.height / 2); [self addChild:bg];

        _fanfareSound = [SKAction playSoundFileNamed:@"VikingMathApp_Fanfare.wav" waitForCompletion:NO];

        NSError* error;
        NSURL* bgMusicURL =[[NSBundle mainBundle] URLForResource:@"VikingMathApp_Drums.wav" withExtension:nil];
        _bgMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:bgMusicURL error:&error];
        _bgMusicPlayer.numberOfLoops = -1;
        [_bgMusicPlayer prepareToPlay];
        [_bgMusicPlayer play];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_bgMusicPlayer stop];
    __weak VMAMainMenuScene* weakSelf = self;
    SKAction* block = [SKAction runBlock:^
                      {
                          VMAGroupsActivityBuildScene* myScene = [[VMAGroupsActivityBuildScene alloc] initWithSize:weakSelf.size];
                          SKTransition* reveal = [SKTransition doorsOpenHorizontalWithDuration:0.5];
                          [weakSelf.view presentScene:myScene transition:reveal];
                      }];
    [self runAction:[SKAction sequence:@[_fanfareSound, block]]];
}

@end
