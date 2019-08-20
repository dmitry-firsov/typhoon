////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2016, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonView+TyphoonOutletTransfer.h"
#import "TyphoonResponder+TyphoonOutletTransfer.h"
#import <objc/runtime.h>

@implementation TyphoonViewClass (TyphoonOutletTransfer)

- (void)setTyphoonNeedTransferOutlets:(BOOL)typhoonNeedTransferOutlets
{
    objc_setAssociatedObject(self, @selector(typhoonNeedTransferOutlets), @(typhoonNeedTransferOutlets), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)typhoonNeedTransferOutlets
{
    return [objc_getAssociatedObject(self, @selector(typhoonNeedTransferOutlets)) boolValue];
}


// Swizzle awakeFromNib
// After the [super awakeFromNib] all the outlets on view will be set
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(awakeFromNib);
        
        Method method = class_getInstanceMethod(class, originalSelector);
        
        void(*originalImp)(id, SEL) = (void (*)(id, SEL)) method_getImplementation(method);
        
        IMP swizzledImp = imp_implementationWithBlock(^void(TyphoonViewClass *view) {
            originalImp(view, originalSelector);
            // When view have superview transfer outlets if needed
            if (view.typhoonNeedTransferOutlets) {
                // recursive search for root view (superview without superview)
                TyphoonViewClass *rootView = [view findRootView:view];
                
                // Change UIViewController outlets properties
                TyphoonResponderClass *nextRexponder = [rootView nextResponder];
                if ([nextRexponder isKindOfClass:[TyphoonViewControllerClass class]]) {
                    [nextRexponder transferConstraintsFromView:view];
                }
                
                // recursive check and change super outlets properties
                [view transferOutlets:rootView
                         transferView:view];
                // Mark that the transportation of finished
                view.typhoonNeedTransferOutlets = NO;
            }
        });
        
        if(!class_addMethod(self, originalSelector, swizzledImp, method_getTypeEncoding(method))) {
            method_setImplementation(method, swizzledImp);
        }
    });
}

- (void)transferOutlets:(TyphoonViewClass *)view
           transferView:(TyphoonViewClass *)transferView
{
    [view transferConstraintsFromView:transferView];
    
    // Optimization. The outlet from view to the subview of TyphoonLoadedView is invalid.
    if (view == transferView) {
        return;
    }
    
    for (TyphoonViewClass *subview in view.subviews) {
        [subview transferOutlets:subview
                    transferView:transferView];
    }
}

- (TyphoonViewClass *)findRootView:(TyphoonViewClass *)view
{
    NSArray *expulsionViewClasses = [self expulsionViewClasses];
    // Optimization. The outlet from view to the UICollectionViewCell is invalid.
    // Outlets cannot be connected to repeating content.
    for (Class expulsionClass in expulsionViewClasses) {
        if ([view isKindOfClass:expulsionClass]) {
            return view;
        }
    }
    
    TyphoonResponderClass *nextRexponder = [view nextResponder];
    if ([nextRexponder isKindOfClass:[TyphoonViewControllerClass class]]) {
        return view;
    }

    if (view.superview) {
        return [view.superview findRootView:view.superview];
    }
    return view;
}

- (NSArray *)expulsionViewClasses
{
#if TARGET_OS_IPHONE || TARGET_OS_TV
    return @[[UITableViewCell class],
             [UICollectionViewCell class]];
#elif TARGET_OS_MAC
    return @[[NSCell class],
             [NSCollectionViewItem class]];
#endif
}

@end
