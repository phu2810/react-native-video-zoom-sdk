//
//  LastFrameManager.m
//  RNZoomUs
//
//  Created by Phu on 4/14/21.
//

#import "CaptureVideoManager.h"

@implementation CaptureVideoManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static CaptureVideoManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];        
    });
    return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
      self.mapCaptures = [NSMutableDictionary new];
  }
  return self;
}

- (void)dealloc {
}

- (void) setLastFrame: (UIImage *) image size:(CGSize) size forKey:(NSString *) key {
    if (size.width > 0 && size.height > 0) {
        NSString *keyMap = [NSString stringWithFormat:@"%@_%@x%@", key, @(size.width), @(size.height)];
        [self.mapCaptures setValue:image forKey:keyMap];
    }
}

- (UIImage *) getLastFrame: (NSString *) key withSize:(CGSize)size {
    if (size.width > 0 && size.height > 0) {
        NSString *keyMap = [NSString stringWithFormat:@"%@_%@x%@", key, @(size.width), @(size.height)];
        return self.mapCaptures[keyMap];
    }
    return nil;
}

- (void) resetCaptures {
    [self.mapCaptures removeAllObjects];
}

@end
