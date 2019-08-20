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
#import "TyphoonComponentFactory.h"


/**
 * TyphoonStoryboard will inject properties for each view controller created by storyboard.
 *
 * Normally, TyphoonStoryboard injection performed by view controller's type. But if you want to specify definition
 * for view controller injection - use view controller's 'typhoonKey'runtime property.
 *
 * To specify 'typhoonKey' in storyboard IB, select your view controller, navigate to 'identity inspector'(cmd+option+3) tab,
 * section 'User Defined Runtime Attributes'. Add new row with columns:
 * @code
 * Key Path : typhoonKey
 * Type     : String
 * Value    : #set your definition selector string here#
 * @endcode
 */
NS_CLASS_AVAILABLE(10_10, 5_0)
@interface TyphoonStoryboard : TyphoonStoryboardClass

@property(nonatomic, strong) id<TyphoonComponentFactory> factory;
@property(nonatomic, strong) NSString *storyboardName;

+ (TyphoonStoryboard *)storyboardWithName:(NSString *)name bundle:(NSBundle *)storyboardBundleOrNil;

+ (TyphoonStoryboard *)storyboardWithName:(NSString *)name factory:(id<TyphoonComponentFactory>)factory bundle:(NSBundle *)bundleOrNil;

- (TyphoonViewControllerClass *)instantiatePrototypeViewControllerWithIdentifier:(NSString *)identifier;

@end


#if (!TARGET_OS_IPHONE || TARGET_OS_TV)

@interface NSStoryboard (TyphoonStoryboard)
- (id)instantiateViewControllerWithIdentifier:(NSString *)identifier;
@end

#endif
