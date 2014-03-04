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

static NSString* BOATPROWNODENAME = @"GroupActivity_BoatProw";
static NSString* BOATNODENAME = @"GroupActivity_Boat";

#endif
