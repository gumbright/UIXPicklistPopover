//
//  PicklistPopover.h
//  popover
//
//  Created by Guy Umbright on 5/5/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)();
typedef void (^UIXPicklistPopoverResultBlock)(NSArray* selectedItems, NSArray* selectedItemIndexes);

typedef enum
{
    UIXPicklistPopoverControllerSingleSelect=0,
    UIXPicklistPopoverControllerMultipleSelect
} UIXPicklistPopoverControllerSelectionType;

@interface UIXPicklistPopover : NSObject

+ (void) picklistPopoverFromRect:(CGRect) rect
                          inView:(UIView*) view
                           items:(NSArray*) items
                   selectedItems:(NSArray*) selectedItems
                          search:(BOOL) search
                   selectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
              onSelectionChanged:(UIXPicklistPopoverResultBlock) selectionChangedBlock;

@end
