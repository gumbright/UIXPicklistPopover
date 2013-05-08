//
//  UIXPicklistPopover.m
//  popover
//
//  Created by Guy Umbright on 5/5/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//
/*
 Copyright (c) 2013 Umbright Consulting
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Neither the name of Umbright Consulting nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Umbright Consulting ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Umbright Consulting BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIXPicklistPopover.h"

//static UIPopoverController *_sharedPopover;
//static UIXPicklistPopoverResultBlock _selectionChangedBlock;
//static VoidBlock _cancelBlock;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark PicklistPopoverTableViewControllerDelegate

@class UIXPicklistPopoverTableViewController;

@protocol PicklistPopoverTableViewControllerDelegate
- (void) tableControllerCancelled:(UIXPicklistPopoverTableViewController*) tableController;
- (void) tableControllerDidSelectItem:(UIXPicklistPopoverTableViewController*) tableController;

//optional
//- (BOOL) displayAddWhenNoMatch;
//- (void) addItemSelected;
@end

#pragma mark UIXPicklistPopoverTableViewController Interface
@interface UIXPicklistPopoverTableViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, assign) BOOL search;
@property (nonatomic, assign) BOOL toolbarButtons;
@property (nonatomic, unsafe_unretained) NSDictionary* userInfo;
@property (nonatomic, assign) UIXPicklistPopoverControllerSelectionType selectionType;

@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) UINavigationBar* navBar;
@property (nonatomic, assign) CGFloat contentWidth;

@property (nonatomic, copy) NSArray* valuesArray;
@property (nonatomic, unsafe_unretained) NSObject<PicklistPopoverTableViewControllerDelegate>* picklistTableDelegate;

@property (nonatomic, strong) NSMutableSet* selectedValues;
@property (nonatomic, strong) NSArray* filteredValues;

@property (nonatomic, copy) UIXPicklistPopoverResultBlock selectionChangedBlock;

- (void) setSelectedItems:(NSArray *)selectedItems;
- (NSArray*) getSelectedItems;
- (NSArray*) getSelectedItemIndexes;

@end

@implementation UIXPicklistPopoverTableViewController
/////////////////////////////////////////////////////
//
////////////////////////////////////////////////////
- (id) init
{
    if (self = [super init])
    {
        self.contentWidth = 320;
        
        self.search = NO;
        self.toolbarButtons = NO;
        self.selectionType = UIXPicklistPopoverControllerSingleSelect;
        self.selectedValues = [NSMutableSet set];
    }
    return self;
}

- (void) dealloc
{
    self.searchBar = nil;
    self.table = nil;
    self.navBar = nil;
    self.selectedValues = nil;
    self.filteredValues = nil;
    self.selectionChangedBlock = nil;
//    self.myPopoverController = nil;
    
#if !(__has_feature(objc_arc))
        [super dealloc];
#endif
}
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) loadView
{
    CGFloat currentY = 0;
    
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth, 640)];
    
    if (self.toolbarButtons)
    {
        UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth, 44)];
        navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@""];
        
        UIBarButtonItem* bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target: self
                                                                             action:@selector(cancelPressed:)];
        item.leftBarButtonItem = bbi;
#if !(__has_feature(objc_arc))
            [bbi release];
#endif        
        
        [navBar setItems:[NSArray arrayWithObject:item]];
        [v addSubview:navBar];
        
        self.navBar = navBar;
#if !(__has_feature(objc_arc))
            [navBar release];
            [item release];
#endif
        currentY = CGRectGetMaxY(self.navBar.frame);
    }
    
    if (self.search)
    {
        UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, currentY, self.contentWidth, 44)];
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchBar.delegate = self;
        [v addSubview:searchBar];
        self.searchBar = searchBar;
        
#if !(__has_feature(objc_arc))
            [searchBar release];
#endif        
        currentY = CGRectGetMaxY(self.searchBar.frame);
    }
    
    UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, self.contentWidth, v.bounds.size.height - CGRectGetMaxY(self.searchBar.frame))
                                              style:UITableViewStylePlain];
    table.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    table.dataSource = self;
    table.delegate = self;
    [v addSubview:table];
    self.table = table;
#if !(__has_feature(objc_arc))
        [table release];
#endif
    self.view = v;
#if !(__has_feature(objc_arc))
        [v release];
#endif
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) cancelPressed:(id) sender
{
    [self.picklistTableDelegate tableControllerCancelled:self];
}

#pragma mark UITableViewDatasource
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredValues.count;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
    cell = [tableView dequeueReusableCellWithIdentifier:@"SimplePicklist"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimplePicklist"];
#if !(__has_feature(objc_arc))
            [cell autorelease];
#endif
    }
    
 	cell.textLabel.text = [self.filteredValues objectAtIndex:[indexPath row]];
    
    if ([self.selectedValues containsObject:[self.filteredValues objectAtIndex:[indexPath row]]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectionType == UIXPicklistPopoverControllerMultipleSelect)
    {
        //toggle the checkmark
        NSString* value = [self.filteredValues objectAtIndex:[indexPath row]];
        BOOL selected = [self.selectedValues containsObject:value];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!selected)
        {
            [self.selectedValues addObject:value];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            [self.selectedValues removeObject:value];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self handleSelect];
        [self.picklistTableDelegate tableControllerDidSelectItem:self];
    }
    else
    {
        if (self.selectedValues.count > 0)
        {
            NSInteger ndx = [self.valuesArray indexOfObject:[self.selectedValues anyObject]];
            NSIndexPath* path = [NSIndexPath indexPathForRow:ndx inSection:0];
            [tableView cellForRowAtIndexPath:path].accessoryType = UITableViewCellAccessoryNone;
        }
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        /*
         * Update selected label.
         */
        [self setSelectedLabel:[self.filteredValues objectAtIndex:[indexPath row]]];
        [self handleSelect];
        [self.picklistTableDelegate tableControllerDidSelectItem:self];
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) handleSelect
{
    NSArray* selected = [self getSelectedItems];
    NSArray* selectedIndexes = [self getSelectedItemIndexes];
    
    if (self.selectionChangedBlock)
    {
        self.selectionChangedBlock(selected, selectedIndexes, self.userInfo);
    }
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) setSelectedLabel:(NSString*) selectedLabel
{
    if (self.selectionType == UIXPicklistPopoverControllerSingleSelect)
    {
        [self.selectedValues removeAllObjects];
    }
    
    if (selectedLabel)
    {
        [self.selectedValues addObject:selectedLabel];
    }
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setValuesArray:(NSArray *)values
{
    _valuesArray = values;
    _filteredValues = _valuesArray;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setSelectedItems:(NSArray *)selectedItems
{
    self.selectedValues = [NSMutableSet setWithArray:selectedItems];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSArray*) getSelectedItems
{
    return self.selectedValues.allObjects;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSArray*) getSelectedItemIndexes
{
    NSMutableArray* indexes = [NSMutableArray arrayWithCapacity:self.selectedValues.count];
    
    for (NSString* s in self.selectedValues.allObjects)
    {
        NSInteger ndx = [self.valuesArray indexOfObject:s];
        [indexes addObject:[NSNumber numberWithInteger:ndx]];
    }
    
    return indexes;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //!!!this can be better optimized by looking at the length change, etc
    if (searchText.length)
    {
        NSIndexSet* indexes = [self.valuesArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString* s = obj;
            return ([s rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound);;
        }];
        
        self.filteredValues = [self.valuesArray objectsAtIndexes:indexes];
        
    }
    else
    {
        self.filteredValues  = self.valuesArray;
    }

    [self.table reloadData];
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIXPicklistPopover () <UIPopoverControllerDelegate>

@property (nonatomic, assign) UIXPicklistPopoverControllerSelectionType selectcionType;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, copy) UIXPicklistPopoverResultBlock selectionBlock;
#if !(__has_feature(objc_arc))
@property (nonatomic, retain) UIPopoverController* pop;
#else
@property (nonatomic, strong) UIPopoverController* pop;
#endif
@end

@implementation UIXPicklistPopover

- (void) dealloc
{
    self.userInfo = nil;
    self.items = nil;
    self.pop = nil;
    
#if !(__has_feature(objc_arc))
        [super dealloc];
#endif
}

///////////////////////////////////////
- (id) initWithSelectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
                                  items:(NSArray*) items
                onSelectionChangedBlock:(UIXPicklistPopoverResultBlock) selectionChangedBlock
{
    if (self = [super init])
    {
        self.selectcionType = selectionType;
        self.items = items;
        self.selectionBlock = selectionChangedBlock;

        self.selectedItems = nil;
        self.showSearchBar = NO;
        self.showAddItemWhenEmpty = NO;
        self.emptyItemSelectBlock = nil;
        self.permittedArrowDirections = UIPopoverArrowDirectionAny;
        self.userInfo = nil;
    }
    
    return self;
}

- (void) presentPicklistPopoverFromRect:(CGRect) rect inView:(UIView*) view
{
    UIXPicklistPopoverTableViewController* tableController = [[UIXPicklistPopoverTableViewController alloc] init];
    tableController.search = self.showSearchBar;
    tableController.selectionType = self.selectcionType;
    tableController.valuesArray = self.items;
    tableController.userInfo = self.userInfo;
    tableController.selectionChangedBlock = self.selectionBlock;
    [tableController setSelectedItems:self.selectedItems];
    tableController.picklistTableDelegate = self;

    self.pop = [[UIPopoverController alloc] initWithContentViewController: tableController];
#if !(__has_feature(objc_arc))
        [tableController autorelease];
#endif
//    self.pop.delegate = self;
    
    [self.pop presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.pop.delegate = nil;
    self.pop = nil;
    //call dismissed block
}

- (void) tableControllerDidSelectItem:(UIXPicklistPopoverTableViewController*) tableController
{
    if (tableController.selectionType == UIXPicklistPopoverControllerSingleSelect)
    {
        [self.pop dismissPopoverAnimated:YES];
        self.pop.delegate = nil;
#if !(__has_feature(objc_arc))
        [self.pop release];
        self.pop = nil;
#endif
    }
}

@end
