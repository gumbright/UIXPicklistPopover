//
//  UIXPicklistPopoverController.m
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import "UIXPicklistPopoverController.h"

@class UIXPicklistPopoverController;

@interface UIXPicklistPopoverTableController : UITableViewController

@property (nonatomic, assign) NSInteger numEntries;
@property (nonatomic, assign) UIXPicklistPopoverController* myPopoverController;

- (void) multiselectDone;
@end

@implementation UIXPicklistPopoverController

@synthesize tableViewController=_tableViewController;
@synthesize strings=_strings;
@synthesize picklistPopeverDelegate=_picklistPopeverDelegate;
@synthesize multiSelect=_multiSelect;

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
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType != UITableViewCellAccessoryCheckmark)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else 
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else 
    {
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
    NSMutableArray *values, *indexes;
    
    values = [NSMutableArray array];
    indexes = [NSMutableArray array];
    
    for (NSUInteger ndx=0; ndx < self.tableViewController.numEntries; ++ndx)
    {
        NSIndexPath* path = [NSIndexPath indexPathForRow:ndx inSection:0];
        UITableViewCell* cell = [self.tableViewController.tableView cellForRowAtIndexPath:path];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [values addObject:[self.strings objectAtIndex:[path row]]];
            [indexes addObject:[NSNumber numberWithInteger:ndx]];
        }
    }
    
    [self.picklistPopeverDelegate picklistPopover:self 
                                multiSelectValues: values
                                  selectedIndexes:indexes];
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
