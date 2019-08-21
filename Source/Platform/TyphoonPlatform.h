////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2017, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#if TARGET_OS_IPHONE || TARGET_OS_TV

#import <UIKit/UIKit.h>
#define TyphoonViewControllerBaseClass UIViewController
#define TyphoonViewControllerClass UIViewController
#define TyphoonViewClass UIView
#define TyphoonStoryboardClass UIStoryboard
#define TyphoonResponderClass UIResponder

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>
#define TyphoonViewControllerBaseClass NSResponder
#define TyphoonViewControllerClass NSViewController
#define TyphoonViewClass NSView
#define TyphoonStoryboardClass NSStoryboard
#define TyphoonResponderClass NSResponder

#endif

