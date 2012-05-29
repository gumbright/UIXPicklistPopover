//
//  UIXPicklistPopoverController.m
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import "UIXPicklistPopoverController.h"

@class UIXPicklistPopoverController;

@interface UIXPicklistPopoverController ()
@property (nonatomic, strong) NSMutableSet* selectedLabels;
@end

@interface UIXPicklistPopoverTableController : UITableViewController

@property (nonatomic, assign) NSInteger numEntries;
@property (nonatomic, assign) UIXPicklistPopoverController* myPopoverController;

@end

@implementation UIXPicklistPopoverController

@synthesize tableViewController=_tableViewController;
@synthesize strings=_strings;
@synthesize picklistPopeverDelegate=_picklistPopeverDelegate;
@synthesize multiSelect=_multiSelect;
@synthesize selectedLabels=_selectedLabels;

//////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////
+ (UIXPicklistPopoverController*) picklistPopoverWithStrings:(NSArray*) array
{
    UIXPicklistPopoverTableController* tvc = [[UIXPicklistPopoverTableController alloc] initWithStyle:UITableViewStylePlain];
    
    //Honestly I consider this a horrible hack, but as the popover is such a pain and the idea is this to be static
    //I can cope.
    tvc.numEntries = array.count;

    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:tvc];
    UIXPicklistPopoverController* popController = [[UIXPicklistPopoverController alloc] initWithContentViewController:nc];
    
    tvc.tableView.dataSource = popController;
    tvc.tableView.delegate = popController;
    tvc.myPopoverController = popController;

    popController.tableViewController = tvc;
    
    popController.strings = array;
    popController.delegate = popController;

    return popController;
}

- (id)initWithContentViewController:(UIViewController *)viewController
{
    if (self = [super initWithContentViewController:viewController])
    {
        self.multiSelect = NO;
        self.selectedLabels = [NSMutableSet set];
    }
    
    return self;
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
    return self.strings.count;
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
    
 	cell.textLabel.text = [self.strings objectAtIndex:[indexPath row]];
    
    if ([self.selectedLabels containsObject:[self.strings objectAtIndex:[indexPath row]]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else 
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (self.multiSelect)
    {
        //toggle the checkmark
        NSString* value = [self.strings objectAtIndex:[indexPath row]];
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
            NSInteger ndx = [self.strings indexOfObject:[self.selectedLabels anyObject]];
            NSIndexPath* path = [NSIndexPath indexPathForRow:ndx inSection:0];
            [tableView cellForRowAtIndexPath:path].accessoryType = UITableViewCellAccessoryNone;
        }
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self.picklistPopeverDelegate picklistPopover:self
                                        selectedValue:[self.strings objectAtIndex:[indexPath row]] 
                                              atIndex:[indexPath row]];
        
        [self dismissPopoverAnimated:YES];
    }
}

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

/*
///////////////////////////////////////////
//
///////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/
- (void) multiselectDone
{
    NSArray* values = [[self.selectedLabels allObjects] sortedArrayUsingSelector:@selector(localizedCompare:)];
    NSMutableArray* indexes = [NSMutableArray array];
    
    for (NSString* s in values)
    {
        NSInteger ndx = [self.strings indexOfObject:s];
        [indexes addObject:[NSNumber numberWithInteger:ndx]];
    }

    [self.picklistPopeverDelegate picklistPopover:self 
                                multiSelectValues: values
                                  selectedIndexes:indexes];
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
    
    [self.selectedLabels addObject:selectedLabel];
}
@end

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
@implementation UIXPicklistPopoverTableController

@synthesize numEntries=_numEntries;
@synthesize myPopoverController=_myPopoverController;


///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) viewDidLoad
{
    CGSize sz = CGSizeMake(320,self.numEntries * self.tableView.rowHeight);
    self.contentSizeForViewInPopover = sz;
}

///////////////////////////////////////////
//
///////////////////////////////////////////
- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target: self 
                                                                                           action:@selector(cancelPressed:)];
    
    if (self.myPopoverController.multiSelect == YES)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target: self 
                                                                                               action:@selector(donePressed:)];
    }
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
@end  
