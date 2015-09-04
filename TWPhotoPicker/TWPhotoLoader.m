//
//  TWImageLoader.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "TWPhotoLoader.h"

NSInteger UNLIMITED_NUMBER_OF_PHOTOS = -1;

@interface TWPhotoLoader ()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (readwrite, copy, nonatomic) void(^loadBlock)(NSArray *photos, NSError *error);
@end



@implementation TWPhotoLoader

+ (TWPhotoLoader *)sharedLoader {
    static TWPhotoLoader *loader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[TWPhotoLoader alloc] init];
    });
    return loader;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _maxNumberOfPhotosToLoad = UNLIMITED_NUMBER_OF_PHOTOS;
        _shouldSortNewestToOldest = YES;
    }

    return self;
}


+ (void)loadAllPhotosInGroup:(NSURL*) groupURL andCompletion:(void (^)(NSArray *photos, NSError *error))completion {
    [[TWPhotoLoader sharedLoader] setLoadBlock:completion];
    [[TWPhotoLoader sharedLoader] startLoadingWithGroup:groupURL];
}

+ (void)loadAllPhotos:(void (^)(NSArray *photos, NSError *error))completion {
    [[TWPhotoLoader sharedLoader] setLoadBlock:completion];
    [[TWPhotoLoader sharedLoader] startLoading];
}

- (void)startLoadingWithGroup:(NSURL*) aGroup {
    [self.allPhotos removeAllObjects];
    
    [self.assetsLibrary groupForURL:aGroup resultBlock:^(ALAssetsGroup *group) {
        if(group) {
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
            
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                [self addPhotoToSet:result stop:stop];
            };

            [group enumerateAssetsWithOptions: [self getEnumerateOptions ] usingBlock: assetsEnumerationBlock];
        
            self.loadBlock(self.allPhotos, nil);
        } else {
            self.loadBlock(self.allPhotos, nil);
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to load photos");
            self.loadBlock(self.allPhotos, error);
    }];
}

- (NSEnumerationOptions)getEnumerateOptions
{
    return (NSEnumerationOptions) (self.shouldSortNewestToOldest? NSEnumerationReverse : 0);
}

- (void)addPhotoToSet:(ALAsset *)result stop:(BOOL *)stop
{
    if (result) {
                    TWPhoto *photo = [TWPhoto new];
                    photo.asset = result;
                    [self.allPhotos addObject:photo];

                    if([self hasMaxNumberOfPhotos])
                    {
                        *stop = YES;
                    }
                }
}

- (BOOL)hasMaxNumberOfPhotos
{
    return self.maxNumberOfPhotosToLoad != UNLIMITED_NUMBER_OF_PHOTOS && [self.allPhotos count] >= self.maxNumberOfPhotosToLoad;
}

- (void)startLoading {
    [self.allPhotos removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        [self addPhotoToSet:result stop:stop];
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0) {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group enumerateAssetsWithOptions: [self getEnumerateOptions ] usingBlock: assetsEnumerationBlock];
            }
        }
        
        if (group == nil) {
            self.loadBlock(self.allPhotos, nil);
        }
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError *error) {
        self.loadBlock(nil, error);
    }];
}

- (NSMutableArray *)allPhotos {
    if (_allPhotos == nil) {
        _allPhotos = [NSMutableArray array];
    }
    return _allPhotos;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

@end
