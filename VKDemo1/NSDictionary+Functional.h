//
//  NSDictionary+Functional.h
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

@import Foundation;

@interface NSDictionary <K,V> (Functional)
- (void)each:(void(^)(K key, V value))block;
- (NSArray *)map:(id(^)(K key, V value))block;
@end
