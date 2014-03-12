//
//  VMADropZoneManager.m
//  VikingMathApp
//
//  Created by Spencer Drayton on 12/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import "VMADropZoneManager.h"
#import "VMAGroupsActivityBuildScene.h"
#import "VMARenderableComponent.h"
#import "VMAEntityFactory.h"
#import "VMAEntityManager.h"
#import "VMADropZone.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation VMADropZoneManager
{
    NSMutableArray* _dropZones;
    VMAGroupsActivityBuildScene* _scene;
    AppDelegate* _appDelegate;
}

-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene spriteSize:(CGSize)spriteSize;
{
    if (self = [super init])
    {
        _scene = invokingScene;
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

        // configure drop zones
        _dropZones = [NSMutableArray arrayWithCapacity:MAXDROPZONESLOTS];
        for (int i = 0; i < MAXDROPZONESLOTS; i++ )
        {
            VMADropZone* dz = [VMADropZone new];
            dz.index = i;
            dz.occupied = NO;

            // build a rect
            dz.rect = CGRectMake(DROPZONEOFFSET,
                                 invokingScene.size.height - DROPZONEOFFSET - ((i + 1) * spriteSize.height),
                                 spriteSize.width + DROPZONEOFFSET,
                                 spriteSize.height + DROPZONEOFFSET);

            // build a highlight entity
            dz.entity = [[_appDelegate entityFactory] createDropzoneHighlightMaskForRect:dz.rect withParent:_scene];
            _dropZones[i] = dz;
        }
    }
    return self;
}

-(VMADropZone*)pointContainedByOccupiedDropZoneSlot:(CGPoint)point;
{
    VMADropZone* retVal = nil;
    for (VMADropZone* dz in _dropZones)
    {
        if (CGRectContainsPoint(dz.rect, point) && dz.occupied == YES)
        {
            retVal = dz;
            break;
        }
    }
    return retVal;

}

-(VMADropZone*)rectIntersectsUnoccupiedDropZoneSlot:(CGRect)rect
{
    VMADropZone* retVal = nil;
    for (VMADropZone* dz in _dropZones)
    {
        if (CGRectIntersectsRect(dz.rect, rect) && dz.occupied == NO)
        {
            retVal = dz;
            break;
        }
    }
    return retVal;
}

-(void)dropzoneRectIntersectedByRect:(CGRect)rect;
{
    [self resetAllHighlights];
    for (VMADropZone* dz in _dropZones)
    {
        VMARenderableComponent * renComp =
        (VMARenderableComponent*) [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                          forEntity:dz.entity];
        if (CGRectIntersectsRect(dz.rect, rect) && dz.occupied == NO)
        {
            renComp.isVisible = YES;
            break;
        }
        else
        {
            renComp.isVisible = NO;
        }
    }
}

-(void)resetAllHighlights
{
    for (VMADropZone* dz in _dropZones)
    {
        VMARenderableComponent * renComp =
            (VMARenderableComponent*) [[_appDelegate entityManager] getComponentOfClass:[VMARenderableComponent class]
                                                                              forEntity:dz.entity];
        renComp.isVisible = NO;
    }
}

-(void)printDebugInfo
{
    for (VMADropZone* dz in _dropZones)
    {
        NSLog(@"Index: %d", dz.index);
        NSLog(@"Occupied: %d", dz.occupied);
    }
    NSLog(@"-------------");
}

@end
