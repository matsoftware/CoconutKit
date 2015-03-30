//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSNullability.h"
#import "HLSViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Overlay view controller displaying binding debugging information
 */
NS_ASSUME_NONNULL_BEGIN
@interface HLSViewBindingDebugOverlayViewController : HLSViewController <UIPopoverControllerDelegate>

/**
 * Show an overlay displaying bound fields in the current key window
 */
+ (void)show;

/**
 * Return the current overlay, nil if none
 */
+ (nullable HLSViewBindingDebugOverlayViewController *)currentBindingDebugOverlayViewController;

/**
 * Animate a frame to highlight a given view on the overlay
 */
- (void)highlightView:(UIView *)view;

@end
NS_ASSUME_NONNULL_END

@interface HLSViewBindingDebugOverlayViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
