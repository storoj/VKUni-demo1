//
//  NSArray+Functional.m
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray(Functional)

- (void)each:(void(^)(id object))block {
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

- (NSArray *)map:(id(^)(id object))block {
    NSMutableArray *result = [NSMutableArray array];
    [self each:^(id object) {
        [result addObject:block(object)];
    }];
    return result;
}

- (void)enumerateSlicesOfCount:(NSUInteger)count withBlock:(void(^)(NSUInteger idx, NSArray *slice))block {
    const NSUInteger numberOfItems = [self count];
    if (numberOfItems == 0) {
        return;
    }
    
    NSRange range = NSMakeRange(0, 0);
    NSUInteger idx = 0;
    do {
        range.location += range.length;
        if (range.location < numberOfItems) {
            range.length = MIN(count, numberOfItems-range.location);
            
            if (range.length > 0) {
                block(idx++, [self subarrayWithRange:range]);
            }
        }
        
    } while (range.location < numberOfItems);
}

@end
