////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2015, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonPlatform.h"

@interface TyphoonViewControllerClass (TyphoonStoryboardIntegration)

@property(nonatomic, strong) NSString *typhoonKey;

- (void)setViewDidLoadNotificationBlock:(void(^)(void))viewDidLoadBlock;

+ (void)swizzleViewDidLoadMethod;

@end
