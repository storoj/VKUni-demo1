//
//  ThumbnailsLayout.m
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

#import "ThumbnailsLayout.h"

typedef void(^ArrayPermutationBlock)(int values[], int count);

static void EnumeratePermutationsOfNumbersArrayWithBlock(int values[], int n, ArrayPermutationBlock block)
{
    if (!block || n == 0) {
        return;
    }
    
    int Q[n];
    for (int i=0; i<n; Q[i] = values[i], i++);
    
    do {
        block(Q, n);
        int i,j;
        
        for (i=n-2; i>=0 && Q[i] >= Q[i+1]; i--);
        
        if (i < 0) { break; }
        
        for (j=i+1; j<n-1 && Q[j+1] > Q[i]; j++) {}
        
#define SWAP_IDX(I, J) { int t = Q[I]; Q[I] = Q[J]; Q[J] = t; }
        SWAP_IDX(i, j)
        
        for (j=i+1; j<=(n-1+i)/2; j++) {
            SWAP_IDX(j, n-j+i);
        }
#undef SWAP_IDX
    } while (1);
}

static void EnumerateSummandsOfNumberWithBlock(int n, int m, ArrayPermutationBlock block)
{
    if (!block || n == 0 || m == 0) {
        return;
    }
    
    int Q[m+1];
    for (int i=0; i<=m; i++) {
        Q[i] = 0;
    }
    
    Q[1] = n;
    
    do {
        block(Q, m+1);
        
        int i=1, s=0;
        do {
            s += Q[i]*i;
            i++;
        } while (i <= m && s < i);
        
        if (i <= m) {
            Q[i]++;
            
            Q[1] = s-i;
            for (int z=2; z<i; z++) {
                Q[z] = 0;
            }
            
        } else {
            break;
        }
    } while (1);
}

static void EnumerateRowsForThumbnailsLayoutWithBlock(int N, int M, ArrayPermutationBlock block)
{
    EnumerateSummandsOfNumberWithBlock(N, M, ^(int summands[], int count) {
        int m = 0;
        for (int i=1; i<count; m += summands[i++]);
        
        int Q[m];
        int k = 0;
        for (int i=1; i<count; i++) {
            for (int j=0; j<summands[i]; j++) {
                Q[k++] = i;
            }
        }
        
        EnumeratePermutationsOfNumbersArrayWithBlock(Q, m, block);
    });
}


static CGFloat AreaDiffByAspectRatio (CGFloat r1, CGFloat r2) {
    return (1-MIN(r1, r2) / MAX(r1, r2));
};

static CGFloat AreaDiffSumByAspectRatio(int n, CGFloat ratios[], CGRect frames[]) {
    CGFloat ratioDiffSum = 0;
    for (int i=0; i<n; i++) {
        const CGSize size = frames[i].size;
        const CGFloat ratio = size.width/size.height;
        ratioDiffSum += AreaDiffByAspectRatio(ratios[i], ratio);
    }
    
    return ratioDiffSum;
}

static void LayoutRow(CGFloat ratios[], int numberOfItems, CGSize rowSize, CGRect *frames)
{
    const CGFloat interItemDistance = 1;
    const CGFloat itemWidth = (rowSize.width - interItemDistance*(numberOfItems-1))/numberOfItems;
    
    CGFloat rowHeight = 0;
    for (int i=0; i<numberOfItems; i++) {
        rowHeight = MAX(rowHeight, itemWidth / ratios[i]);
    }
    rowHeight = MIN(rowHeight, rowSize.height);
    
    for (int i=0; i<numberOfItems; i++) {
        frames[i] = CGRectMake((itemWidth+interItemDistance)*i, 0, itemWidth, rowHeight);
    }
}

static CGFloat LayoutTripleRowVariantGetX(CGFloat tallImageRatio, CGFloat upperSideImageRatio, CGFloat bottomSideImageRatio)
{
    const CGFloat D = tallImageRatio/sqrt(upperSideImageRatio * bottomSideImageRatio);
    
    CGFloat x = 0;
#define TEST(VAL) if (x == 0 && VAL >= 0 && VAL <= 1) x = VAL;
    TEST(1+D)
    TEST(1-D)
    TEST(1-1/D)
    TEST(1+1/D)
#undef TEST
    
    return x;
}

static BOOL LayoutTripleRowVariant(CGFloat ratios[], CGSize rowSize, CGRect *frames, int tallImageIdx, int upperImageIdx, int bottomImageIdx, BOOL alignLeft)
{
    const CGFloat itemWidth = rowSize.width / 2;
    const CGFloat rowHeight = MIN(itemWidth/ratios[tallImageIdx], rowSize.height);
    const CGFloat tallImageRatio = itemWidth / rowHeight;
    
    const CGFloat x = LayoutTripleRowVariantGetX(tallImageRatio, ratios[upperImageIdx], ratios[bottomImageIdx]);
    
    if (x > 0) {
        const CGFloat upperImageRatio = tallImageRatio / x;
        const CGFloat bottomImageRatio = tallImageRatio / (1-x);
        const CGFloat rightColumnX = itemWidth+2;
        
        frames[tallImageIdx] = CGRectMake(alignLeft ? 0 : rightColumnX, 0, itemWidth, itemWidth/tallImageRatio);
        
        const CGFloat upperImageHeight = itemWidth/upperImageRatio;
        
        frames[upperImageIdx] = CGRectMake(alignLeft ? rightColumnX : 0, 0, itemWidth, upperImageHeight);
        frames[bottomImageIdx] = CGRectMake(alignLeft ? rightColumnX : 0, upperImageHeight+2, itemWidth, itemWidth/bottomImageRatio);
        
        return YES;
    }
    
    return NO;
}

static void LayoutTripleRow(CGFloat ratios[], CGSize rowSize, CGRect *frames)
{
    const int n = 3;
    LayoutRow(ratios, n, rowSize, frames);
    CGFloat ratioDiff = AreaDiffSumByAspectRatio(3, ratios, frames);
    
    CGRect tmpFrames[n];
    
    const int VARIANTS = 3;
    const int DATA[VARIANTS][4] = {
        {0, 1, 2, YES}, {1, 0, 2, NO}, {2, 0, 1, NO}
    };
    
    for (int V=0; V<VARIANTS; V++) {
        if (LayoutTripleRowVariant(ratios, rowSize, tmpFrames, DATA[V][0], DATA[V][1], DATA[V][2], DATA[V][3])) {
            const CGFloat variantRatioDiff = AreaDiffSumByAspectRatio(n, ratios, tmpFrames);
            if (variantRatioDiff < ratioDiff) {
                ratioDiff = variantRatioDiff;
                for (int i=0; i<n; i++) { frames[i] = tmpFrames[i]; }
            }
        }
    }
}

void EnumerateFramesForThumbnails(NSArray <id<ThumbnailDescription>> * thumbnails,
                                  CGSize preferredSize,
                                  void(^block)(NSUInteger idx, id<ThumbnailDescription> thumbnail, CGRect frame))
{
    const CGFloat preferredWidth = preferredSize.width;
    const CGFloat preferredHeight = preferredSize.height;
    
    const int N = (int)[thumbnails count];
    
    CGFloat ratios[N], *ratiosPtr = ratios;
    CGRect finalFrames[N], *finalFramesPtr = finalFrames;
    CGRect tmpFrames[N], *tmpFramesPtr = tmpFrames;
    
    for (int i=0; i<N; i++) {
        ratios[i] = [thumbnails[i] ratio];
    }
    
    __block CGFloat minimumAreaDiff = 1000;
    EnumerateRowsForThumbnailsLayoutWithBlock(N, 5, ^(int rowSizes[], int numberOfRows) {
        const CGFloat preferredRowHeight = preferredHeight / numberOfRows;
        const CGSize preferredRowSize = CGSizeMake(preferredWidth, preferredRowHeight);
        
        CGFloat y = 0;
        int thumbnailIdx = 0;
        for (int rowIdx=0; rowIdx<numberOfRows; rowIdx++) {
            const int numberOfCols = rowSizes[rowIdx];
            
            switch (numberOfCols) {
                case 3:
                {
                    LayoutTripleRow(&ratiosPtr[thumbnailIdx], preferredRowSize, &tmpFramesPtr[thumbnailIdx]);
                    break;
                }
                    
                default:
                {
                    LayoutRow(&ratiosPtr[thumbnailIdx], numberOfCols, preferredRowSize, &tmpFramesPtr[thumbnailIdx]);
                    break;
                }
            }
            
            {
                CGFloat bottomY = 0;
                for (int i=0; i<numberOfCols; i++) {
                    const int itemIdx = thumbnailIdx+i;
                    tmpFramesPtr[itemIdx] = CGRectOffset(tmpFramesPtr[itemIdx], 0, y);
                    bottomY = MAX(bottomY, CGRectGetMaxY(tmpFramesPtr[itemIdx]));
                }
                y = bottomY + 2;
            }
            
            thumbnailIdx += numberOfCols;
        }
        
        const CGFloat currentAreaDiff = AreaDiffSumByAspectRatio(N, ratiosPtr, tmpFramesPtr);
        if (currentAreaDiff < minimumAreaDiff) {
            minimumAreaDiff = currentAreaDiff;
            
            for (int i=0; i<N; i++) { finalFramesPtr[i] = tmpFramesPtr[i]; }
        }
        
    });
    
    for (int i=0; i<N; i++) {
        block(i, thumbnails[i], finalFrames[i]);
    }
}
