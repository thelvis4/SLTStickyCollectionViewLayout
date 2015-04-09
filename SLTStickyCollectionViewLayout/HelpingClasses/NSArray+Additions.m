//
//  NSArray+Additions.m
//  SLTStickyCollectionViewLayout
//
//  Created by Andrei Raifura on 4/9/15.
//  Copyright (c) 2015 YOPESO. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (BOOL)containsObjectAtIndex:(NSUInteger)index {
    return (index < [self count]);
}

@end