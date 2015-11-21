//
//  NSDictionary+Functional.m
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

#import "NSDictionary+Functional.h"

@implementation NSDictionary(Functional)

- (void)each:(void(^)(id key, id value))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(key, obj);
    }];
}

- (NSArray *)map:(id(^)(id key, id value))block {
    NSMutableArray *result = [NSMutableArray array];
    [self each:^(id key, id value) {
        [result addObject:block(key, value)];
    }];
    return [result copy];
}

@end
