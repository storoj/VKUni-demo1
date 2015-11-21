//
//  ViewController.m
//  VKDemo1
//
//  Created by Alexey Storozhev on 21/11/15.
//  Copyright © 2015 Aleksey Storozhev. All rights reserved.
//

#import "ViewController.h"
#import <VKSdkFramework/VKSdk.h>

static NSString *const kCellIdentifier = @"Cell";

@interface PhotoCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end





@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSNumber *loadingOffsetMarker;
@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _photos = [NSMutableArray array];
    }
    return self;
}

- (void)loadView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    self.view = collectionView;
    self.collectionView = collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadNextPhotos];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.photos.count-10) {
        [self loadNextPhotos];
    }
}

#pragma mark Data Loading

- (void)loadPhotosWithOffset:(NSInteger)offset count:(NSInteger)count {
    if (self.loadingOffsetMarker != nil && [self.loadingOffsetMarker integerValue] == offset) {
        return;
    }
    
    NSLog(@"offset: %d", (int)offset);
    
    self.loadingOffsetMarker = @(offset);
    
    VKRequest *request = [[VKApi photos] prepareRequestWithMethodName:@"getUserPhotos"
                                                        andParameters:@{
                                                                        @"user_id" : @(34),
                                                                        @"offset" : @(offset),
                                                                        @"count" : @(count),
                                                                        @"sort" : @(0),
                                                                        @"photo_sizes" : @(1)
                                                                        }
                                                        andHttpMethod:@"POST"
                                                      andClassOfModel:[VKPhotoArray class]];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        VKPhotoArray *photosArray = response.parsedModel;
        [self.photos addObjectsFromArray:photosArray.items];
        [self.collectionView reloadData];
        
        self.loadingOffsetMarker = nil;
    } errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
        self.loadingOffsetMarker = nil;
    }];
}

- (void)loadNextPhotos {
    [self loadPhotosWithOffset:[self.photos count] count:20];
}

@end
