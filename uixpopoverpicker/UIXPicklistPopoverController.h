//
//  UIXPicklistPopoverController.h
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIXPicklistPopoverController;
@class UIXPicklistPopoverTableController;

@protocol UIXPicklistPopoverControllerDelegate

@required
- (void) picklistPopover:(UIXPicklistPopoverController*) picklistPopoverController
           selectedValue:(NSString*) selectedValue 
                 atIndex:(NSInteger) selectedIndex;

- (void) picklistPopoverDismissed:(UIXPicklistPopoverController *)picklistPopoverController;
@end

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
@interface UIXPicklistPopoverController : UIPopoverController <UIPopoverControllerDelegate, 
                                                               UITableViewDataSource,
                                                               UITableViewDelegate>

@property (nonatomic, strong) UIXPicklistPopoverTableController* tableViewController;
@property (nonatomic, assign) NSObject<UIXPicklistPopoverControllerDelegate>* picklistPopeverDelegate;
@property (nonatomic, copy) NSArray* strings;

//set width
//max rows displayed

+ (UIXPicklistPopoverController*) picklistPopoverWithStrings:(NSArray*) array;

@end
