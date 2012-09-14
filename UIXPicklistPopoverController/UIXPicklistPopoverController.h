//
//  UIXPicklistPopoverController.h
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Guy Umbright. All rights reserved.
//
/*
 Copyright (c) 2012, Guy Umbright
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
  * Neither the name of the Guy Umbright nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Guy Umbright ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Guy Umbright BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

@class UIXPicklistPopoverController;
@class UIXPicklistPopoverTableController;

@protocol UIXPicklistPopoverControllerDelegate <NSObject>

@required
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
