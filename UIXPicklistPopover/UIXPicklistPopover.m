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

static UIPopoverController *_sharedPopover;
static UIXPicklistPopoverResultBlock _selectionChangedBlock;
//static VoidBlock _cancelBlock;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark PicklistPopoverTableViewControllerDelegate
@protocol PicklistPopoverTableViewControllerDelegate
- (void) tableControllerCancelled;
- (void) tableControllerDidSelectItem;
@end

#pragma mark UIXPicklistPopoverTableViewController Interface
@interface UIXPicklistPopoverTableViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, assign) BOOL search;
@property (nonatomic, assign) BOOL toolbarButtons;
@property (nonatomic, assign) UIXPicklistPopoverControllerSelectionType selectionType;

@property (nonatomic, copy) NSArray* valuesArray;
@property (nonatomic, weak) NSObject<PicklistPopoverTableViewControllerDelegate>* picklistTableDelegate;

- (void) setSelectedItems:(NSArray *)selectedItems;
- (NSArray*) getSelectedItems;
- (NSArray*) getSelectedItemIndexes;

@end

@interface UIXPicklistPopoverTableViewController ()

@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UITableView* table;
@property (nonatomic, strong) UINavigationBar* navBar;
@property (nonatomic, assign) CGFloat contentWidth;
// @property (nonatomic, strong) NSArray* tableData;

@property (nonatomic, strong) NSMutableSet* selectedValues;
@property (nonatomic, strong) NSArray* filteredValues;
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
        
        //        self.tableData = [NSArray arrayWithObjects:@"Alpha",@"Beta",@"Gamma",@"Omega",@"Toaster",@"Poptart",@"Watermelon",@"Fruit bat",@"Breakfast Cereal",
        //                          @"Llamas",@"Very small rocks",@"GoldenTablets",@"Chicken wire",@"Duck Table",@"Pigeon Cable",
        //                          @"Loose women",@"Evangelicals",@"PC",@"Mac",@"iOS",@"Android",@"Weasel",@"Squirrel",@"Chipmumk",@"Otter",@"Ferret",@"House cat",@"Bibo",@"Lucky Boy",
        //                          @"Batz Maru",@"Godzilla",@"Rodan",@"Ghidra",@"Ren",@"Stimpy",nil];
        self.search = NO;
        self.toolbarButtons = NO;
        self.selectionType = UIXPicklistPopoverControllerSingleSelect;
        self.selectedValues = [NSMutableSet set];
    }
    return self;
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
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth, 44)];
        self.navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@""];
        item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target: self
                                                                               action:@selector(cancelPressed:)];
        [self.navBar setItems:[NSArray arrayWithObject:item]];
        [v addSubview:self.navBar];
        currentY = CGRectGetMaxY(self.navBar.frame);
    }
    
    if (self.search)
    {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, currentY, self.contentWidth, 44)];
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        [v addSubview:self.searchBar];
        currentY = CGRectGetMaxY(self.searchBar.frame);
    }
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, self.contentWidth, v.bounds.size.height - CGRectGetMaxY(self.searchBar.frame))
                                              style:UITableViewStylePlain];
    self.table.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.table.dataSource = self;
    self.table.delegate = self;
    [v addSubview:self.table];
    
    self.view = v;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cancelPressed:(id) sender
{
    [self.picklistTableDelegate tableControllerCancelled];
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
        
        [self.picklistTableDelegate tableControllerDidSelectItem];
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
        
        [self.picklistTableDelegate tableControllerDidSelectItem];
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

- (void) setValuesArray:(NSArray *)values
{
    _valuesArray = values;
    _filteredValues = _valuesArray;
}

- (void) setSelectedItems:(NSArray *)selectedItems
{
    self.selectedValues = [NSMutableSet setWithArray:selectedItems];
}

- (NSArray*) getSelectedItems
{
    return self.selectedValues.allObjects;
}

- (NSArray*) getSelectedItemIndexes
{
    NSMutableArray* indexes = [NSMutableArray arrayWithCapacity:self.selectedValues.count];
    
    for (NSString* s in self.selectedValues.allObjects)
    {
        NSInteger ndx = [self.valuesArray indexOfObject:s];
        [indexes addObject:[NSNumber numberWithInteger:ndx]];
    }
    
    return indexes;
    //    NSArray* values = [[self.tableViewController.selectedLabels allObjects] sortedArrayUsingSelector:@selector(localizedCompare:)];
    //    NSMutableArray* indexes = [NSMutableArray array];
    //
    //    for (NSString* s in values)
    //    {
    //        NSInteger ndx = [self.strings indexOfObject:s];
    //        [indexes addObject:[NSNumber numberWithInteger:ndx]];
    //    }
}

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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIPopoverController (Blocks)
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
//- (void) tableControllerCancelled
//{
//    [_sharedPopover dismissPopoverAnimated:YES];
//    
//    if (_cancelBlock) {
//        _cancelBlock();
//    }
//}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) tableControllerDidSelectItem
{
    UIXPicklistPopoverTableViewController* tableController = (UIXPicklistPopoverTableViewController*) _sharedPopover.contentViewController;
    if (tableController.selectionType == UIXPicklistPopoverControllerSingleSelect)
    {
        [_sharedPopover dismissPopoverAnimated:YES];
    }
    
    NSArray* selected = [tableController getSelectedItems];
    NSArray* selectedIndexes = [tableController getSelectedItemIndexes];
    
    if (_selectionChangedBlock)
    {
        _selectionChangedBlock(selected, selectedIndexes);
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    UIXPicklistPopoverTableViewController* tableController = (UIXPicklistPopoverTableViewController*) popoverController.contentViewController;
    NSArray* selected = [tableController getSelectedItems];
    NSArray* selectedIndexes = [tableController getSelectedItemIndexes];
    
    if (_selectionChangedBlock) {
        _selectionChangedBlock(selected, selectedIndexes);
    }
    
    return YES;
}

@end



@interface UIXPicklistPopover ()
@end

@implementation UIXPicklistPopover

+ (UIPopoverController *)sharedPopover
{
    return _sharedPopover;
}

+ (void) picklistPopoverFromRect:(CGRect) rect
                   inView:(UIView*) view
                    items:(NSArray*) items
            selectedItems:(NSArray*) selectedItems
                   search:(BOOL) search
            selectionType:(UIXPicklistPopoverControllerSelectionType) selectionType
              onSelectionChanged:(UIXPicklistPopoverResultBlock) selectionChangedBlock;
//                 onCancel:(VoidBlock) cancelBlock
{
    _selectionChangedBlock = [selectionChangedBlock copy];
//    _cancelBlock = [cancelBlock copy];
    
    UIXPicklistPopoverTableViewController* tableController = [[UIXPicklistPopoverTableViewController alloc] init];
    tableController.search = search;
    tableController.selectionType = selectionType;
    tableController.valuesArray = items;
    [tableController setSelectedItems:selectedItems];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: tableController];
    tableController.picklistTableDelegate = popover;
    [popover presentPopoverFromRect:rect inView:view.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    _sharedPopover = popover;
}
@end
