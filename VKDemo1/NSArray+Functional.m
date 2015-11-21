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

@end
