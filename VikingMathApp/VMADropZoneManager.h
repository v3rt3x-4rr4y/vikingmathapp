//
//  VMADropZoneManager.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 12/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VMAGroupsActivityBuildScene;
@class VMADropZone;
@class VMAEntity;


@interface VMADropZoneManager : NSObject

/**
 Initialiser.
 @param invokingScene the SkScene object which instantiates this manager
 @param spriteSize the size of the sprites for the entities which will be housed within the drop zone slots
 maintained by this manager.
*/
-(instancetype)initWithScene:(VMAGroupsActivityBuildScene*)invokingScene spriteSize:(CGSize)spriteSize;

/**
 Updates the visible state of the highlight entity for the drop zone which intersects with the supplied rectangle
 (if any)
 @param rect the rectangle to test for intersection
 */
-(void)highlightDropzoneIntersectedByRect:(CGRect)rect;

-(VMADropZone*)rectIntersectsUnoccupiedDropZoneSlot:(CGRect)rect;

-(VMADropZone*)pointContainedByDropZoneSlot:(CGPoint)point occupied:(BOOL)isOccupied;

-(void)resetAllHighlights;

-(void)printDebugInfo;

@end
