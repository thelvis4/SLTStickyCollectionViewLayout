//
//  SLTPosition.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/9/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "SLTPosition.h"

SLTPosition SLTPositionMake(NSInteger line, NSInteger column) {
    SLTPosition position;
    position.line = line;
    position.column = column;
    
    return position;
}