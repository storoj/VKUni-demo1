//
//  PhotosLayout.h
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

@import UIKit;

@class PhotosLayout;

@protocol UICollectionViewDelegatePhotosLayout <NSObject>
- (CGFloat)photoLayout:(PhotosLayout *)layout aspectRatioForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface PhotosLayout : UICollectionViewLayout
@end
