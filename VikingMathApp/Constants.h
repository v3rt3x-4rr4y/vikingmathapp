//
//  Constants.h
//  VikingMathApp
//
//  Created by Spencer Drayton on 04/03/2014.
//  Copyright (c) 2014 Spencer Drayton. All rights reserved.
//

#ifndef VikingMathApp_Constants_h
#define VikingMathApp_Constants_h

typedef NS_OPTIONS(int, VMATouchEventType)
{
    VMATouchEventTypeBegan,
    VMATouchEventTypeMoved,
    VMATouchEventTypeCancelled,
    VMATouchEventTypeEnded
};

static NSString* BOATPROWNODENAME = @"GroupActivity_Prow";
static NSString* BOATNODENAME = @"GroupActivity_Boat";
static NSString* BOATNODENAMEDEBUG = @"GroupActivity_mBoat";
static NSString* BOATMASKNODENAME = @"GroupActivity_Mask-Boat";
static NSString* BOATHILITENODENAME = @"GroupActivity_Hilite-Boat";
static NSString* BACKGROUND = @"GroupVikingsActivity_Background";
static NSString* BOATSHEDNODENAME = @"GroupActivity_Shed";
static NSString* MOBILEBOATNODENAMEPREFIX = @"MOBILE";
static NSString* USERDATAENTITYIDKEY = @"eid";
static NSString* USERDATAENTITYISDRAGGINGKEY = @"isDragging";
static const int BOATSHEDOFFSET = 90;
static const int DROPZONEOFFSET = 10;

#endif
