//
//  ThumbnailsLayout.h
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

@import CoreGraphics;
@import Foundation;

@protocol ThumbnailDescription <NSObject>
- (CGFloat)ratio;
@end

void EnumerateFramesForThumbnails(NSArray <id<ThumbnailDescription>> * thumbnails,
                                  CGSize preferredSize,
                                  void(^block)(NSUInteger idx, id<ThumbnailDescription> thumbnail, CGRect frame));
