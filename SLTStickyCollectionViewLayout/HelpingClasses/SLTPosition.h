//
//  SLTPosition.h
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/9/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct SLTPosition {
    NSInteger line;
    NSInteger column;
} SLTPosition;


SLTPosition SLTPositionMake(NSInteger line, NSInteger column);
