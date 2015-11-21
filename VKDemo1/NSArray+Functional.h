//
//  NSArray+Functional.h
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

@import Foundation;

@interface NSArray <T> (Functional)

- (void)each:(void(^)(T object))block;
- (NSArray *)map:(id(^)(T object))block;

@end
