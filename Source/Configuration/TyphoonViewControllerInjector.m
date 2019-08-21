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

#import "TyphoonPlatform.h"

#import "TyphoonViewControllerInjector.h"
#import "TyphoonViewController+TyphoonStoryboardIntegration.h"
#import "TyphoonView+TyphoonDefinitionKey.h"

#import "TyphoonComponentFactory+TyphoonDefinitionRegisterer.h"


#import <objc/runtime.h>

//-------------------------------------------------------------------------------------------
#pragma mark - TyphoonViewControllerInjector

@implementation TyphoonViewControllerInjector

+ (void)load
{
    [TyphoonViewControllerBaseClass swizzleViewDidLoadMethod];
}

- (void)injectPropertiesForViewController:(TyphoonViewControllerClass *)viewController withFactory:(id)factory
{
    [self injectPropertiesForViewController:viewController withFactory:factory storyboard:nil];
}

- (void)injectPropertiesForViewController:(TyphoonViewControllerClass *)viewController withFactory:(id<TyphoonComponentFactory>)factory storyboard:(TyphoonStoryboardClass *)storyboard
{
    if (storyboard && viewController.storyboard && ![viewController.storyboard isEqual:storyboard]) {
        return;
    }
    else if (viewController.typhoonKey.length > 0) {
        [factory inject:viewController withSelector:NSSelectorFromString(viewController.typhoonKey)];
    }
    else {
        [factory inject:viewController];
    }

    if ([viewController isKindOfClass:[TyphoonViewControllerClass class]]) {
        NSArray<__kindof TyphoonViewControllerClass *> *childViewControllers;
        
#if TARGET_OS_IPHONE || TARGET_OS_TV
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            childViewControllers = ((UITabBarController *)viewController).viewControllers;
        } else {
            childViewControllers = viewController.childViewControllers;
        }
#elif TARGET_OS_MAC
        childViewControllers = viewController.childViewControllers;
#endif
        
        for (TyphoonViewControllerClass *childViewController in childViewControllers) {
            if (storyboard && childViewController.storyboard && ![childViewController.storyboard isEqual:storyboard]) {
                continue;
            }
            [self injectPropertiesForViewController:childViewController withFactory:factory storyboard:storyboard];
        }
        
        if ([viewController isViewLoaded]) {
            [self injectPropertiesInView:viewController.view withFactory:factory];
        } else {
            __weak __typeof (viewController) weakViewController = viewController;
            [viewController setViewDidLoadNotificationBlock:^{
                [self injectPropertiesInView:weakViewController.view withFactory:factory];
            }];
        }
    }
    
#if (!(TARGET_OS_IPHONE || TARGET_OS_TV))
    if ([viewController isKindOfClass:[NSWindowController class]]) {
        TyphoonViewControllerClass *typhoonViewController = [(NSWindowController *)viewController contentViewController];
        [self injectPropertiesForViewController:typhoonViewController withFactory:factory storyboard:storyboard];
    }
#endif
}

- (void)injectPropertiesInView:(TyphoonViewClass *)view withFactory:(id)factory
{
    if (view.typhoonKey.length > 0) {
        [factory inject:view withSelector:NSSelectorFromString(view.typhoonKey)];
    }
    
    if ([view.subviews count] == 0) {
        return;
    }
    
    for (TyphoonViewClass *subview in view.subviews) {
        [self injectPropertiesInView:subview withFactory:factory];
    }
}

@end
