//
//  UIXPicklistPopoverController.m
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import "UIXPicklistPopoverController.h"

@interface UIXPicklistPopoverTableController : UITableViewController

@property (nonatomic, assign) NSInteger numEntries;

@end

@implementation UIXPicklistPopoverController

@synthesize tableViewController=_tableViewController;
@synthesize strings=_strings;
@synthesize picklistPopeverDelegate=_picklistPopeverDelegate;

//////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////
+ (UIXPicklistPopoverController*) picklistPopoverWithStrings:(NSArray*) array
{
    UIXPicklistPopoverTableController* tvc = [[UIXPicklistPopoverTableController alloc] initWithStyle:UITableViewStylePlain];
    
    //Honestly I consider this a horrible hack, but as the popover is such a pain and the idea is this to be static
    //I can cope.
    tvc.numEntries = array.count;

    UIXPicklistPopoverController* popController = [[UIXPicklistPopoverController alloc] initWithContentViewController:tvc];
    
    tvc.tableView.dataSource = popController;
    tvc.tableView.delegate = popController;
    
    popController.strings = array;
    popController.delegate = popController;
    
    return popController;
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
    //get index and value
    //call delegate
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.picklistPopeverDelegate picklistPopover:self
                                    selectedValue:[self.strings objectAtIndex:[indexPath row]] 
                                          atIndex:[indexPath row]];
    
    [self dismissPopoverAnimated:YES];
    //dismiss
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.picklistPopeverDelegate picklistPopoverDismissed:self];
}

/*
///////////////////////////////////////////
//
///////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/
@end

@implementation UIXPicklistPopoverTableController

@synthesize numEntries=_numEntries;

- (void) viewDidLoad
{
    CGSize sz = CGSizeMake(320,self.numEntries * self.tableView.rowHeight);
    self.contentSizeForViewInPopover = sz;
}

//- (void) viewWillAppear:(BOOL)animated
//{
//    CGSize sz = CGSizeMake(320,[self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0] * self.tableView.rowHeight);
//    self.contentSizeForViewInPopover = sz;
//    [super viewWillAppear:animated];
//}
@end  
