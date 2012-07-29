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

@protocol UIXPicklistPopoverControllerDelegate <NSObject>

@required
//- (void) picklistPopover:(UIXPicklistPopoverController*) picklistPopoverController
//           selectedValue:(NSString*) selectedValue 
//                 atIndex:(NSInteger) selectedIndex;

- (void) picklistPopoverDismissed:(UIXPicklistPopoverController *)picklistPopoverController;

- (void) picklistPopover:(UIXPicklistPopoverController *)picklistPopoverController
          selectedValues: (NSArray*) selectedValues
         selectedIndexes:(NSArray*) selectedIndexes;
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
@property (nonatomic, assign) BOOL multiSelect;
@property (nonatomic, assign) CGFloat contentWidth;

- (id) initWithStrings:(NSArray*) stringArray
           multiSelect:(BOOL) isMultiSelect
        selectedValues:(NSArray*) selectedValues;

- (void)presentPopoverFromRect:(CGRect)rect 
                        inView:(UIView *)view 
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                      animated:(BOOL)animated;

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item 
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                               animated:(BOOL)animated;
/*
 * set title on navigation bar.
 */
- (void)setTitleText:(NSString *)titleText;

@end
