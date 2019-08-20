////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonStoryboard.h"
#import "OCLogTemplate.h"

#import "TyphoonComponentFactory+TyphoonDefinitionRegisterer.h"
#import "TyphoonComponentFactory+Storyboard.h"
#import "TyphoonViewControllerFactory.h"
#import "OCLogTemplate.h"
#import "UIViewController+TyphoonStoryboardIntegration.h"


@implementation TyphoonStoryboard

+ (TyphoonStoryboard *)storyboardWithName:(NSString *)name bundle:(NSBundle *)storyboardBundleOrNil
{
    LogInfo(@"*** Warning *** The TyphoonStoryboard with name %@ doesn't have a TyphoonComponentFactory inside. Is this "
            "intentional? You won't be able to inject anything in its ViewControllers", name);
    return [self storyboardWithName:name factory:nil bundle:storyboardBundleOrNil];
}

+ (TyphoonStoryboard *)storyboardWithName:(NSString *)name factory:(id<TyphoonComponentFactory>)factory bundle:(NSBundle *)bundleOrNil
{
    TyphoonStoryboard *storyboard = (id) [super storyboardWithName:name bundle:bundleOrNil];
    storyboard.factory = factory;
    storyboard.storyboardName = name;
        return storyboard;
}

- (TyphoonViewControllerClass *)instantiatePrototypeViewControllerWithIdentifier:(NSString *)identifier
{
#if TARGET_OS_IPHONE || TARGET_OS_TV
    return [super instantiateViewControllerWithIdentifier:identifier];
#elif TARGET_OS_MAC
    return [super instantiateControllerWithIdentifier:identifier];
#endif
}

#if TARGET_OS_MAC
- (id)instantiateControllerWithIdentifier:(NSString *)identifier {
    return [self instantiateViewControllerWithIdentifier:identifier];
}
#endif

- (id)instantiateViewControllerWithIdentifier:(NSString *)identifier {
    NSAssert(self.factory, @"TyphoonStoryboard's factory property can't be nil!");
    
    TyphoonViewControllerClass *cachedInstance = [TyphoonViewControllerFactory cachedViewControllerWithIdentifier:identifier storyboardName:self.storyboardName factory:self.factory];
    if (cachedInstance) {
        return cachedInstance;
    }
    
    TyphoonViewControllerClass *result = [TyphoonViewControllerFactory viewControllerWithIdentifier:identifier storyboard:self];

    return result;
}

@end
