//
//  UITabBarController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/16/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UITabBarController+HLSExtensions.h"

#import "HLSRuntime.h"

// Associated object keys
static void *s_autorotationModeKey = &s_autorotationModeKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UITabBarController__shouldAutorotate_Imp)(id, SEL) = NULL;
static NSUInteger (*s_UITabBarController__supportedInterfaceOrientations_Imp)(id, SEL) = NULL;
static BOOL (*s_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp)(id, SEL, NSInteger) = NULL;

// Swizzled method implementations
static BOOL swizzled_UITabBarController__shouldAutorotate_Imp(UITabBarController *self, SEL _cmd);
static NSUInteger swizzled_UITabBarController__supportedInterfaceOrientations_Imp(UITabBarController *self, SEL _cmd);
static BOOL swizzled_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp(UITabBarController *self, SEL _cmd, NSInteger toInterfaceOrientation);

@implementation UITabBarController (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    // No swizzling occurs on iOS < 6 since those two methods do not exist
    s_UITabBarController__shouldAutorotate_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                       @selector(shouldAutorotate),
                                                                                       (IMP)swizzled_UITabBarController__shouldAutorotate_Imp);
    s_UITabBarController__supportedInterfaceOrientations_Imp = (NSUInteger (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                                           @selector(supportedInterfaceOrientations),
                                                                                                           (IMP)swizzled_UITabBarController__supportedInterfaceOrientations_Imp);
    s_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp = (BOOL (*)(id, SEL, NSInteger))HLSSwizzleSelector(self,
                                                                                                                        @selector(shouldAutorotateToInterfaceOrientation:),
                                                                                                                        (IMP)swizzled_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp);
}

#pragma mark Accessors and mutators

- (HLSAutorotationMode)autorotationMode
{
    NSNumber *autorotationModeNumber = objc_getAssociatedObject(self, s_autorotationModeKey);
    if (! autorotationModeNumber) {
        return HLSAutorotationModeDefault();
    }
    else {
        return [autorotationModeNumber integerValue];
    }
}

- (void)setAutorotationMode:(HLSAutorotationMode)autorotationMode
{
    objc_setAssociatedObject(self, s_autorotationModeKey, [NSNumber numberWithInteger:autorotationMode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

static BOOL swizzled_UITabBarController__shouldAutorotate_Imp(UITabBarController *self, SEL _cmd)
{
    BOOL containerShouldAutorotate = (*s_UITabBarController__shouldAutorotate_Imp)(self, _cmd);
    if (! containerShouldAutorotate) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndChildren:
        case HLSAutorotationModeContainerAndVisibleChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                if (! viewController.shouldAutorotate) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return containerShouldAutorotate;
}

static NSUInteger swizzled_UITabBarController__supportedInterfaceOrientations_Imp(UITabBarController *self, SEL _cmd)
{
    BOOL containerSupportedInterfaceOrientations = (*s_UITabBarController__supportedInterfaceOrientations_Imp)(self, _cmd);
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndChildren:
        case HLSAutorotationModeContainerAndVisibleChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                containerSupportedInterfaceOrientations &= viewController.supportedInterfaceOrientations;
            }
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return containerSupportedInterfaceOrientations;
}

static BOOL swizzled_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp(UITabBarController *self, SEL _cmd, NSInteger toInterfaceOrientation)
{
    // We call the super implementation here (in case it does some bookkeeping, e.g.), but discard the result so that
    // we can implement all rotation modes correctly (UITabBarController does not call the super method, and
    // calls the -shouldAutorotateToInterfaceOrientation on its top view controller in a strange way, which leads
    // to the UIViewController implementation not being called on the top view controller)
    (*s_UITabBarController__shouldAutorotateToInterfaceOrientation_Imp)(self, _cmd, toInterfaceOrientation);
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndChildren:
        case HLSAutorotationModeContainerAndVisibleChildren: {
            for (UIViewController *viewController in self.viewControllers) {
                if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            break;
        }
    }
    
    return YES;
}
