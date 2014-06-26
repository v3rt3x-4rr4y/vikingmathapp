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
static NSString* BOATNODENAME = @"GroupActivity_BoatViking";
static NSString* BOATTEXTUREATLASNAME = @"longship.atlas";
static NSString* BOATNODENAMEDEBUG = @"GroupActivity_mBoat";
static NSString* BOATMASKNODENAME = @"GroupActivity_Mask-Boat";
static NSString* BOATHILITENODENAME = @"GroupActivity_Hilite-Boat";
static NSString* SHEDHILITENODENAME = @"GroupActivity_Hilite-Shed";
static NSString* BACKGROUND = @"GroupVikingsActivity_Background";
static NSString* BOATSHEDNODENAME = @"GroupActivity_Shed";
static NSString* VIKINGNODENAME = @"GroupActivity_Viking";
static NSString* ONPOINTZONENODENAME = @"GroupVikingsActivity_OnPointZone";
static NSString* LAUNCHBUTTONNODENAME = @"launchButton";
static NSString* MOBILEBOATNODENAMEPREFIX = @"MOBILE";
static NSString* USERDATAENTITYIDKEY = @"eid";
static NSString* USERDATAENTITYISDRAGGINGKEY = @"isDragging";
static const int BOATSHEDOFFSET = 90;
static const int DROPZONEOFFSET = 20;
static const int VIKINGONPOINTXPOS = 760;
static const int VIKINGONPOINTYPOS = 405;
static const int LAUNCHBUTTONXPOS = 80;
static const int LAUNCHBUTTONYPOS = 80;
static const int MAXDROPZONESLOTS = 7;
static const int MAXVIKINGSPERLONGSHIP = 5;
static const int VIKINGSPRITEHEIGHT = 55;
static const float VIKING_MOVE_POINTS_PER_SEC = 65;
static const float VIKING_ROTATE_RADIANS_PER_SEC = 4;

#endif
