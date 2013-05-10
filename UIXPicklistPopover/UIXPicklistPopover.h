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

typedef enum
{
    UIXPicklistPopoverAccessoryViewTop=0,
    UIXPicklistPopoverAccessoryViewBottom
} UIXPicklistPopoverAccessoryViewPosition;

@protocol UIXPicklistPopoverDatasource

- (NSUInteger) numberOfItems;
- (NSString*) itemAtIndex:(NSUInteger) index;
- (void) searchTermChanged:(NSString*) searchTerm;

@end

@interface UIXPicklistPopover : NSObject

- (id) initWithSelectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
                       items:(NSArray*) items
     onSelectionChangedBlock:(UIXPicklistPopoverResultBlock) selectionChangedBlock;

- (id) initWithSelectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
                  datasource:(NSObject<UIXPicklistPopoverDatasource>*) datasource
     onSelectionChangedBlock:(UIXPicklistPopoverResultBlock) selectionChangedBlock;

- (id) dismissPicklistPopoverAnimated:(BOOL) animated;

@property (nonatomic, copy) NSArray* selectedItems;
@property (nonatomic, assign) BOOL showSearchBar;

@property (nonatomic, assign) BOOL showAddItemWhenEmpty;
@property (nonatomic, copy) VoidBlock emptyItemSelectBlock;

@property (nonatomic, assign) NSInteger permittedArrowDirections;

@property (nonatomic, strong) NSDictionary* userInfo;

@property (nonatomic, strong) UIView* accessoryView;
@property (nonatomic, assign) UIXPicklistPopoverAccessoryViewPosition accessoryViewPosition;

//datasource mode
@property (nonatomic, unsafe_unretained) NSObject<UIXPicklistPopoverDatasource>* datasource;

- (void) presentPicklistPopoverFromRect:(CGRect) rect inView:(UIView*) view;

@end
