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

@protocol PicklistPopoverTableViewControllerDatasource 
- (NSUInteger) numberOfItems;
- (NSString*) itemAtIndex:(NSUInteger) index;
- (void) searchTermChanged:(NSString*) searchString;
@end

@protocol PicklistPopoverTableViewControllerDelegate
- (void) tableControllerCancelled:(UIXPicklistPopoverTableViewController*) tableController;
- (void) tableControllerDidSelectItem:(UIXPicklistPopoverTableViewController*) tableController;

//optional
//- (BOOL) displayAddWhenNoMatch;
//- (void) addItemSelected;
@end

#pragma mark UIXPicklistPopoverTableViewController Interface
@interface UIXPicklistPopoverTableViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

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
@property (nonatomic, unsafe_unretained) NSObject<PicklistPopoverTableViewControllerDatasource>* tableDatasource;

@property (nonatomic, strong) UIView* accessoryView;
@property (nonatomic, assign) UIXPicklistPopoverAccessoryViewPosition accessoryViewPosition;

@property (nonatomic, strong) NSMutableSet* selectedIndicies;

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
        self.tableDatasource = nil;
        self.accessoryViewPosition = UIXPicklistPopoverAccessoryViewTop;
        self.selectedIndicies = [NSMutableSet set];
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
    self.accessoryView = nil;
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
    
    CGFloat preTableHeight=0, postTableHeight=0;
    if (self.accessoryView != nil)
    {
        CGRect accessoryFrame = self.accessoryView.frame;
        switch (self.accessoryViewPosition)
        {
            case UIXPicklistPopoverAccessoryViewTop:
            {
                preTableHeight = self.accessoryView.bounds.size.height;
                accessoryFrame.origin.y = currentY;
            }
                break;
                
            case UIXPicklistPopoverAccessoryViewBottom:
            {
                postTableHeight = self.accessoryView.bounds.size.height;
                accessoryFrame.origin.y = v.bounds.size.height - postTableHeight;
                self.accessoryView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            }
                break;
        }
        
        accessoryFrame.origin.x = 0;
        accessoryFrame.size.width = v.bounds.size.width;
        
        self.accessoryView.frame = accessoryFrame;
        
       [v addSubview:self.accessoryView];
        
        currentY += preTableHeight;
    }
    
    CGRect tableRect = CGRectMake(0, currentY, self.contentWidth, v.bounds.size.height - (CGRectGetMaxY(self.searchBar.frame) + preTableHeight + postTableHeight));
    
    UITableView* table = [[UITableView alloc] initWithFrame:tableRect
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
    if (self.tableDatasource != nil)
    {
        return [self.tableDatasource numberOfItems];
    }
    else
    {
        return self.filteredValues.count;
    }
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
    
    NSString* itemText;
    if (self.tableDatasource != nil)
    {
        itemText = [self.tableDatasource itemAtIndex:indexPath.row];
    }
    else
    {
        itemText = [self.filteredValues objectAtIndex:indexPath.row];
    }
    
 	cell.textLabel.text = itemText;
    if ([self.selectedValues containsObject:[self.filteredValues objectAtIndex:[indexPath row]]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedIndicies addObject:indexPath];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedIndicies removeObject:indexPath];
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
            [self.selectedIndicies addObject:indexPath];
        }
        else
        {
            [self.selectedValues removeObject:value];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.selectedIndicies removeObject:indexPath];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self handleSelect];
        [self.picklistTableDelegate tableControllerDidSelectItem:self];
    }
    else
    {
        if (self.selectedIndicies.count > 0)
        {
            NSIndexPath* path = [self.selectedIndicies anyObject];
            [tableView cellForRowAtIndexPath:path].accessoryType = UITableViewCellAccessoryNone;
        }
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.selectedIndicies addObject:indexPath];
        /*
         * Update selected label.
         */
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [self setSelectedLabel:cell.textLabel.text];
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
    
    //indexes only generated for non datasource mode (at least for now)
    if (self.tableDatasource == nil)
    {
        for (NSString* s in self.selectedValues.allObjects)
        {
            NSInteger ndx = [self.valuesArray indexOfObject:s];
            [indexes addObject:[NSNumber numberWithInteger:ndx]];
        }
    }
    return indexes;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.tableDatasource != nil)
    {
        [self.tableDatasource searchTermChanged:searchText];
    }
    else
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
    }
    
    [self.table reloadData];
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIXPicklistPopover () <UIPopoverControllerDelegate>

@property (nonatomic, assign) UIXPicklistPopoverControllerSelectionType selectionType;
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

- (void) commonInit
{
    self.selectedItems = nil;
    self.showSearchBar = NO;
    self.showAddItemWhenEmpty = NO;
    self.emptyItemSelectBlock = nil;
    self.permittedArrowDirections = UIPopoverArrowDirectionAny;
    self.accessoryViewPosition = UIXPicklistPopoverAccessoryViewTop;
    self.userInfo = nil;
}

///////////////////////////////////////
- (id) initWithSelectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
                                  items:(NSArray*) items
                onSelectionChangedBlock:(UIXPicklistPopoverResultBlock) selectionChangedBlock
{
    if (self = [super init])
    {
        [self commonInit];
        self.selectionType = selectionType;
        self.items = items;
        self.selectionBlock = selectionChangedBlock;
    }
    
    return self;
}

- (id) initWithSelectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
                  datasource:(NSObject<UIXPicklistPopoverDatasource>*) datasource
     onSelectionChangedBlock:(UIXPicklistPopoverResultBlock) selectionChangedBlock
{
    if (self = [super init])
    {        
        [self commonInit];
        self.selectionType = selectionType;
        self.datasource = datasource;
        self.selectionBlock = selectionChangedBlock;
    }
    
    return self;
}

- (void) presentPicklistPopoverFromRect:(CGRect) rect inView:(UIView*) view
{
    UIXPicklistPopoverTableViewController* tableController = [[UIXPicklistPopoverTableViewController alloc] init];
    tableController.search = self.showSearchBar;
    tableController.selectionType = self.selectionType;
    tableController.userInfo = self.userInfo;
    tableController.selectionChangedBlock = self.selectionBlock;
    [tableController setSelectedItems:self.selectedItems];
    tableController.picklistTableDelegate = self;
    if (self.accessoryView != nil)
    {
        tableController.accessoryView = self.accessoryView;
        tableController.accessoryViewPosition = self.accessoryViewPosition;
    }

    if (self.datasource)
    {
        tableController.tableDatasource = self;
    }
    else
    {
        tableController.valuesArray = self.items;
    }
    
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

- (void) dismissPicklistPopoverAnimated:(BOOL) animated
{
    [self.pop dismissPopoverAnimated:animated];
    self.pop = nil;
}

- (NSUInteger) numberOfItems
{
    return [self.datasource numberOfItems];
}

- (NSString*) itemAtIndex:(NSUInteger) index
{
    return [self.datasource itemAtIndex:index];
}

- (void) searchTermChanged:(NSString*) searchString
{
    [self.datasource searchTermChanged:searchString];
}


@end
