//
//  PhotosLayout.m
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

#import "PhotosLayout.h"
#import "ThumbnailsLayout.h"
#import "NSArray+Functional.h"

@interface ThumbnailDescription : NSObject <ThumbnailDescription>
@property (nonatomic, assign, readonly) CGFloat ratio;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;

- (instancetype)initWithRatio:(CGFloat)ratio indexPath:(NSIndexPath *)indexPath;
+ (instancetype)descriptionWithRatio:(CGFloat)ratio indexPath:(NSIndexPath *)indexPath;

@end

@implementation ThumbnailDescription
- (instancetype)initWithRatio:(CGFloat)ratio indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (self) {
        _ratio = ratio;
        _indexPath = indexPath;
    }
    return self;
}

+ (instancetype)descriptionWithRatio:(CGFloat)ratio indexPath:(NSIndexPath *)indexPath {
    return [[self alloc] initWithRatio:ratio indexPath:indexPath];
}

@end



@implementation PhotosLayout
{
    CGSize _size;
    NSArray <NSNumber *> *_offsets;
    NSArray <NSArray <UICollectionViewLayoutAttributes *>*>* _attributeGroups;
}

- (void)prepareLayout {
    const CGSize pageSize = self.collectionView.bounds.size;
    id<UICollectionViewDelegatePhotosLayout> delegate = (id)self.collectionView.delegate;
    
    const NSUInteger numberOfPhotos = [self.collectionView numberOfItemsInSection:0];
    const NSUInteger batchSize = 9;
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    for (NSInteger i=0; i<numberOfPhotos; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [thumbnails addObject:[ThumbnailDescription descriptionWithRatio:[delegate photoLayout:self aspectRatioForItemAtIndexPath:indexPath]
                                                               indexPath:indexPath]];
    }
    
    _size = CGSizeZero;
    
    NSMutableArray *attributeGroups = [NSMutableArray array];
    NSMutableArray *offsets = [NSMutableArray array];
    
    [thumbnails enumerateSlicesOfCount:batchSize withBlock:^(NSUInteger batchIdx, NSArray *slice) {
        const CGFloat yOffset = _size.height + 10;
        [offsets addObject:@(yOffset)];
        
        NSMutableArray *group = [NSMutableArray array];
        
        EnumerateFramesForThumbnails(slice, pageSize, ^(NSUInteger idx, ThumbnailDescription *thumbnail, CGRect frame) {
            frame = CGRectOffset(frame, 0, yOffset);
            
            UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:thumbnail.indexPath];
            attrs.frame = frame;
            
            [group addObject:attrs];
            
            _size.width = MAX(_size.width, CGRectGetMaxX(frame));
            _size.height = MAX(_size.height, CGRectGetMaxY(frame));
        });
        
        [attributeGroups addObject:[group copy]];
    }];
    
    _attributeGroups = [attributeGroups copy];
    _offsets = [offsets copy];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if ([_offsets count] == 0) {
        return nil;
    }
    
    const NSUInteger idx = [_offsets indexOfObject:@(rect.origin.y)
                                     inSortedRange:NSMakeRange(0, [_offsets count])
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
                                       return [obj1 compare:obj2];
                                   }];
    
    NSMutableArray *result = [NSMutableArray array];
    
    {
        NSUInteger bottomIdx = idx;
        while (bottomIdx < [_offsets count] && [_offsets[bottomIdx] doubleValue] < CGRectGetMaxY(rect)) {
            [result addObjectsFromArray:_attributeGroups[bottomIdx]];
            bottomIdx++;
        }
    }
    
    {
        NSInteger upperIdx = idx;
        while (upperIdx >= 0 && [_offsets[upperIdx] doubleValue] > CGRectGetMinY(rect)) {
            [result addObjectsFromArray:_attributeGroups[upperIdx]];
            upperIdx--;
        }
    }
    
    return [result copy];
}

- (CGSize)collectionViewContentSize {
    return _size;
}

@end
