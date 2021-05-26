//
//  CaptureVideoManager.h
//  RNZoomUs
//
//  Created by Phu on 4/14/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaptureVideoManager : NSObject {
}

@property (nonatomic, strong) NSMutableDictionary *mapCaptures;

+ (id)sharedManager;

- (void) setLastFrame: (UIImage *) image size:(CGSize) size forKey:(NSString *) key;
- (UIImage *) getLastFrame: (NSString *) key withSize:(CGSize) size;
- (void) resetCaptures;

@end

NS_ASSUME_NONNULL_END
