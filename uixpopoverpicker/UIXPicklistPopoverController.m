//
//  UIXPicklistPopoverController.m
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import "UIXPicklistPopoverController.h"

@class UIXPicklistPopoverController;


@protocol UIXPicklistPopoverTableControllerDelegate

- (void) itemsSelected:(NSArray*) selectedValues
              atIndexes:(NSArray*) selectedIndexes;

@end

@interface UIXPicklistPopoverController () <UIXPicklistPopoverTableControllerDelegate>
@end

@interface UIXPicklistPopoverTableController : UITableViewController

@property (nonatomic, assign) NSInteger numEntries;
@property (nonatomic, unsafe_unretained) UIXPicklistPopoverController* myPopoverController;
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, copy) NSArray* stringArray;
@property (nonatomic, strong) NSMutableSet* selectedLabels;
@property (nonatomic, assign) BOOL multiSelect;
@property (nonatomic, unsafe_unretained) NSObject<UIXPicklistPopoverTableControllerDelegate>* privateDelegate;
@property (nonatomic, copy) NSArray* selectedValues;
@end


@implementation UIXPicklistPopoverController

@synthesize tableViewController=_tableViewController;
@synthesize picklistPopeverDelegate=_picklistPopeverDelegate;
@synthesize multiSelect=_multiSelect;
@synthesize contentWidth=_contentWidth;

//////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////
- (void)setTitleText:(NSString *)titleText {
    [[[[[self tableViewController] navigationController] navigationBar] topItem]setTitle:titleText];
}

//////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////
- (id) initWithStrings:(NSArray*) stringArray multiSelect:(BOOL) isMultiSelect selectedValues:(NSArray*) selectedValues
{
    UIXPicklistPopoverTableController* tvc = [[UIXPicklistPopoverTableController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:tvc];
    tvc.stringArray = stringArray;
    tvc.multiSelect = isMultiSelect;
    tvc.selectedValues = selectedValues;
    
    if (self = [super initWithContentViewController:nc])
    {
        tvc.privateDelegate = self;
        self.multiSelect = isMultiSelect;
        self.contentWidth = 320;
        self.strings = stringArray;
        self.tableViewController = tvc;
        
        tvc.myPopoverController = self;

        tvc.contentWidth = self.contentWidth;
    }
    
    return self;
}

/*
///////////////////////////////////////////
//
///////////////////////////////////////////
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}
*/

/*
///////////////////////////////////////////
//
///////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
*/


///////////////////////////////////////////
//
///////////////////////////////////////////
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.picklistPopeverDelegate picklistPopoverDismissed:self];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) configurePopover
{
    self.tableViewController.contentWidth = self.contentWidth;
}


///////////////////////////////////////////
//
///////////////////////////////////////////
- (void)presentPopoverFromRect:(CGRect)rect 
                        inView:(UIView *)view 
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                      animated:(BOOL)animated
{
    [self configurePopover];
    [super presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item 
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                               animated:(BOOL)animated
{
    [self configurePopover];
    [super presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) multiselectDone
{
    NSArray* values = [[self.tableViewController.selectedLabels allObjects] sortedArrayUsingSelector:@selector(localizedCompare:)];
    NSMutableArray* indexes = [NSMutableArray array];
    
    for (NSString* s in values)
    {
        NSInteger ndx = [self.strings indexOfObject:s];
        [indexes addObject:[NSNumber numberWithInteger:ndx]];
    }

    [self.picklistPopeverDelegate picklistPopover:self 
                                   selectedValues: values
                                  selectedIndexes:indexes];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) itemsSelected:(NSArray*) selectedValues
             atIndexes:(NSArray*) selectedIndexes;
{
    [self.picklistPopeverDelegate picklistPopover:self
                                    selectedValues:selectedValues
                                          selectedIndexes:selectedIndexes];
    
}
@end

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
@implementation UIXPicklistPopoverTableController

@synthesize numEntries=_numEntries;
@synthesize myPopoverController=_myPopoverController;
@synthesize contentWidth=_contentWidth;
@synthesize selectedLabels=_selectedLabels;
@synthesize privateDelegate=_privateDelegate;

///////////////////////////////////////////
//
///////////////////////////////////////////
- (id) initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style])
    {
        self.selectedLabels = [NSMutableSet set];
        self.contentWidth = 320;
    }
    
    return self;
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) viewDidLoad
{
    CGSize sz = CGSizeMake(self.contentWidth,[self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0] * self.tableView.rowHeight);
    self.contentSizeForViewInPopover = sz;
    
    if (self.selectedValues && self.selectedValues.count)
    {
        if (self.multiSelect)
        {
            for (NSString* s in self.selectedValues)
            {
                if ([self.stringArray containsObject:s])
                {
                    [self.selectedLabels addObject:s];
                }
            }
        }
        else
        {
            NSString* s = [self.selectedValues objectAtIndex:0];
            if ([self.stringArray containsObject:s])
            {
                [self.selectedLabels addObject:s];
            }
        }
    }
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) viewWillAppear:(BOOL)animated
{
    CGSize sz = CGSizeMake(self.contentWidth,self.numEntries * self.tableView.rowHeight);
    self.contentSizeForViewInPopover = sz;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target: self 
                                                                                           action:@selector(cancelPressed:)];
    
    if (self.multiSelect == YES)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target: self 
                                                                                               action:@selector(donePressed:)];
    }
    [self.tableView reloadData];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (IBAction) cancelPressed:(id)sender
{
    [self.myPopoverController dismissPopoverAnimated:YES];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (IBAction) donePressed:(id)sender
{
    [self.myPopoverController multiselectDone];
    [self.myPopoverController dismissPopoverAnimated:YES];
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


///////////////////////////////////////////
//
///////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stringArray.count;
}


///////////////////////////////////////////
//
///////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
    cell = [tableView dequeueReusableCellWithIdentifier:@"SimplePicklist"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimplePicklist"];
    }
    
 	cell.textLabel.text = [self.stringArray objectAtIndex:[indexPath row]];
    
    if ([self.selectedLabels containsObject:[self.stringArray objectAtIndex:[indexPath row]]])
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
    if (self.multiSelect)
    {
        //toggle the checkmark
        NSString* value = [self.stringArray objectAtIndex:[indexPath row]];
        BOOL selected = [self.selectedLabels containsObject:value];
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!selected)
        {
            [self.selectedLabels addObject:value];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            [self.selectedLabels removeObject:value];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        if (self.selectedLabels.count > 0)
        {
            NSInteger ndx = [self.stringArray indexOfObject:[self.selectedLabels anyObject]];
            NSIndexPath* path = [NSIndexPath indexPathForRow:ndx inSection:0];
            [tableView cellForRowAtIndexPath:path].accessoryType = UITableViewCellAccessoryNone;
        }
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        /*
         * Update selected label.
         */
        [self setSelectedLabel:[self.stringArray objectAtIndex:[indexPath row]]];
        
        [self.privateDelegate itemsSelected:@[[self.stringArray objectAtIndex:[indexPath row]]]
                                   atIndexes:@[[NSNumber numberWithInteger:[indexPath row]]]];
        [self.myPopoverController dismissPopoverAnimated:YES];
    }
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) setSelectedLabel:(NSString*) selectedLabel
{
    if (!self.multiSelect)
    {
        [self.selectedLabels removeAllObjects];
    }
    if (selectedLabel) {
        [self.selectedLabels addObject:selectedLabel];
    }
}

@end  
