//
//  TWImageLoader.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "TWPhotoLoader.h"

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
                if (result) {
                    TWPhoto *photo = [TWPhoto new];
                    photo.asset = result;
                    [self.allPhotos insertObject:photo atIndex:0];
                }
        
            };
        
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        
            self.loadBlock(self.allPhotos, nil);
        } else {
            self.loadBlock(self.allPhotos, nil);
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to load photos");
            self.loadBlock(self.allPhotos, error);
    }];
}

- (void)startLoading {
    [self.allPhotos removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            TWPhoto *photo = [TWPhoto new];
            photo.asset = result;
            [self.allPhotos insertObject:photo atIndex:0];
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0) {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
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
