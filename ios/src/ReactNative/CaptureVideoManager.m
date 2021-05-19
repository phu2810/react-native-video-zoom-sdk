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

- (void) setLastFrame: (UIImage *) image forKey:(NSString *) key {
    [self.mapCaptures setValue:image forKey:key];
}

- (UIImage *) getLastFrame: (NSString *) key {
    return self.mapCaptures[key];
}

- (void) resetCaptures {
    [self.mapCaptures removeAllObjects];
}

@end
