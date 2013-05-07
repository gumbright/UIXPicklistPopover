//
//  PicklistPopover.h
//  popover
//
//  Created by Guy Umbright on 5/5/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)();
typedef void (^UIXPicklistPopoverResultBlock)(NSArray* selectedItems, NSArray* selectedItemIndexes, NSDictionary* userInfo);

typedef enum
{
    UIXPicklistPopoverControllerSingleSelect=0,
    UIXPicklistPopoverControllerMultipleSelect
} UIXPicklistPopoverControllerSelectionType;

@interface UIXPicklistPopover : NSObject

+ (UIXPicklistPopover*) picklistPopoverFromRect:(CGRect) rect
                          inView:(UIView*) view
                           items:(NSArray*) items
                   selectedItems:(NSArray*) selectedItems
                          search:(BOOL) search
                        userInfo: (NSDictionary*) userInfo
                   selectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
              onSelectionChanged:(UIXPicklistPopoverResultBlock) selectionChangedBlock;

////////////
- (id) initWithSelectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
                                  items:(NSArray*) items
                onSelectionChangedBlock:(UIXPicklistPopoverResultBlock) selectionChangedBlock;

@property (nonatomic, copy) NSArray* selectedItems;
@property (nonatomic, assign) BOOL showSearchBar;
@property (nonatomic, assign) BOOL showAddItemWhenEmpty;
@property (nonatomic, copy) VoidBlock emptyItemSelectBlock;
@property (nonatomic, assign) NSInteger permittedArrowDirections;
@property (nonatomic, strong) NSDictionary* userInfo;

//- (void) setSelectedItems:(NSArray*) selectedItems;
//- (void) setShowSearchBar:(BOOL) showSearchBar;
//- (void) setShowAddItemWhenEmpty: (BOOL) showAdditemWhenEmpty;
//- (void) setEmptyItemSelectBlock: (VoidBlock) emptyItemSelectBlock;
//- (void) setPermittedArrowDirections:(NSInteger) arrowDirections;

- (void) presentPicklistPopoverFromRect:(CGRect) rect inView:(UIView*) view;

@end
