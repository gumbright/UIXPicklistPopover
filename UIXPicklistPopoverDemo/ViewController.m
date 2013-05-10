//
//  ViewController.m
//  popover
//
//  Created by Guy Umbright on 5/5/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "ViewController.h"
//#import "UIXPicklistPopoverTableViewController.h"
#import "UIXPicklistPopover.h"

@interface ViewController ()
@property (nonatomic, strong) UIPopoverController* pop;
@property (nonatomic, strong) NSArray* values;
@property (nonatomic, strong) UIXPicklistPopover* picklist;
@property (nonatomic, strong) NSArray* datasourceModeData;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.values  = [NSArray arrayWithObjects:@"Alpha",@"Beta",@"Gamma",@"Omega",@"Toaster",@"Poptart",@"Watermelon",@"Fruit bat",@"Breakfast Cereal",
                       @"Llamas",@"Very small rocks",@"GoldenTablets",@"Chicken wire",@"Duck Table",@"Pigeon Cable",
                       @"Loose women",@"Evangelicals",@"PC",@"Mac",@"iOS",@"Android",@"Weasel",@"Squirrel",@"Chipmumk",@"Otter",@"Ferret",@"House cat",@"Bibo",@"Lucky Boy",
                       @"Batz Maru",@"Godzilla",@"Rodan",@"Ghidra",@"Ren",@"Stimpy",nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction) buttonPressed:(UIButton*)sender
//{
//    UIXPicklistPopoverTableViewController* vc = [[UIXPicklistPopoverTableViewController alloc] init];
//    vc.search = YES;
//    vc.selectionType = UIXPicklistPopoverControllerMultipleSelect;
//    vc.valuesArray = self.values;
//
//    
//    self.pop = [[UIPopoverController alloc] initWithContentViewController:vc];
//    [self.pop presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//}

- (IBAction) newWayPressed:(UIButton*)sender
{
    UIXPicklistPopover* picklist = [[UIXPicklistPopover alloc] initWithSelectionType:UIXPicklistPopoverControllerSingleSelect
                                                                          items:self.values
                                                        onSelectionChangedBlock:^(NSArray *selectedItems, NSArray *selectedItemIndexes, NSDictionary *userInfo) {
//                                                            self.picklist = nil;
                                                        }];
    
    picklist.showSearchBar = YES;
    picklist.userInfo = [NSDictionary dictionaryWithObject:@"blahblahblah" forKey:@"blabbing"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 320, 50);
    [button setTitle:@"Create New" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(accessoryPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    picklist.accessoryViewPosition = UIXPicklistPopoverAccessoryViewBottom;
    picklist.accessoryView = button;

#if !(__has_feature(objc_arc))
    [button release];
#endif
    
    [picklist presentPicklistPopoverFromRect:sender.frame inView:self.view];
    
#if !(__has_feature(objc_arc))
        [picklist autorelease];
#endif
    self.picklist = picklist;
    
}

- (IBAction) accessoryPressed:(id)sender
{
    NSLog(@"accessoryPressed");
    [self.picklist dismissPicklistPopoverAnimated:YES];
}

- (IBAction) datasourceModePressed:(UIButton*)sender
{
    self.datasourceModeData = self.values;
    UIXPicklistPopover* picklist = [[UIXPicklistPopover alloc] initWithSelectionType:UIXPicklistPopoverControllerSingleSelect
                                                                               datasource:self
                                                             onSelectionChangedBlock:^(NSArray *selectedItems, NSArray *selectedItemIndexes, NSDictionary *userInfo) {
                                                                 //                                                            self.picklist = nil;
                                                             }];
    
    picklist.showSearchBar = YES;
    picklist.userInfo = [NSDictionary dictionaryWithObject:@"blahblahblah" forKey:@"blabbing"];
    
    [picklist presentPicklistPopoverFromRect:sender.frame inView:self.view];
    
#if !(__has_feature(objc_arc))
    [picklist autorelease];
#endif
    self.picklist = picklist;
    
}

- (NSUInteger) numberOfItems
{
    return self.datasourceModeData.count;
}

- (NSString*) itemAtIndex:(NSUInteger) index
{
    return self.datasourceModeData[index];
}

- (void) searchTermChanged:(NSString*) searchTerm
{
    if (searchTerm.length)
    {
        NSIndexSet* indexes = [self.values indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString* s = obj;
            return ([s rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound);;
        }];
        
        self.datasourceModeData = [self.values objectsAtIndexes:indexes];
    }
    else
    {
        self.datasourceModeData  = self.values;
    }
    
}

@end
