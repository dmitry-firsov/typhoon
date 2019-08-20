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

#import <Foundation/Foundation.h>

NS_CLASS_AVAILABLE(10_10, 5_0)
@interface TyphoonStoryboardProvider : NSObject

- (NSArray *)collectStoryboardsFromBundle:(NSBundle *)bundle;

@end
