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

#import "TyphoonStoryboardResolver.h"
#import "TyphoonStartup.h"
#import "TyphoonStoryboard.h"
#import "TyphoonStoryboardProvider.h"
#import "TyphoonComponentFactory+Storyboard.h"
#import "TyphoonComponentsPool.h"

#import "TyphoonPlatform.h"
#import <objc/runtime.h>

@implementation TyphoonStoryboardResolver

+ (void)load
{
    NSBundle *bundle = [NSBundle mainBundle];
    TyphoonStoryboardProvider *provider = [TyphoonStoryboardProvider new];
    NSArray *resolvingStoryboardNames = [provider collectStoryboardsFromBundle:bundle];
    
    if (resolvingStoryboardNames.count > 0) {
        [self swizzleUIStoryboardWithNames:resolvingStoryboardNames];
    }
}

+ (void)swizzleUIStoryboardWithNames:(NSArray *)storyboardNames
{
    SEL sel = @selector(storyboardWithName:bundle:);
    Method method = class_getClassMethod([TyphoonStoryboardClass class], sel);
    
    id(*originalImp)(id, SEL, id, id) = (id (*)(id, SEL, id, id)) method_getImplementation(method);
    
    IMP adjustedImp = imp_implementationWithBlock(^id(id instance, NSString *name, NSBundle *bundle) {
        if ([instance class] == [TyphoonStoryboardClass class] && [storyboardNames containsObject:name]) {
            TyphoonStoryboard *storyboard = [TyphoonStoryboard storyboardWithName:name factory:nil bundle:bundle];
            [TyphoonComponentFactory setUIFactoryPromiseBlock:^(TyphoonComponentFactory *factory) {
                storyboard.factory = factory;
                @synchronized(self) {
                    id<TyphoonComponentsPool> storyboardPool = [factory storyboardPool];
                    [storyboardPool setObject:storyboardPool forKey:name];
                }
            }];
            return storyboard;
        } else {
            return originalImp(instance, sel, name, bundle);
        }
    });
    
    method_setImplementation(method, adjustedImp);
}

@end
