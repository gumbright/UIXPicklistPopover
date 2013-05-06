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

- (IBAction) fancyPantsPressed:(UIButton*)sender
{
    [UIXPicklistPopover picklistPopoverFromRect:sender.frame
                                      inView:self.view
                                       items:self.values
                               selectedItems:nil
                                      search:YES
                               selectionType:UIXPicklistPopoverControllerSingleSelect
                          onSelectionChanged:^(NSArray *selectedItems, NSArray *selectedItemIndexes) {
                              
                              NSLog(@"%@ %@",selectedItems,selectedItemIndexes);
                              
                          }];
}

- (IBAction) fancyPantsMultiPressed:(UIButton*)sender
{
    [UIXPicklistPopover picklistPopoverFromRect:sender.frame
                                      inView:self.view
                                       items:self.values
                                  selectedItems:[NSArray arrayWithObjects:@"Chicken wire",@"Duck Table",@"Pigeon Cable", nil]
                                      search:YES
                               selectionType:UIXPicklistPopoverControllerMultipleSelect
                          onSelectionChanged:^(NSArray *selectedItems, NSArray *selectedItemIndexes) {
                              
                              NSLog(@"%@ %@",selectedItems,selectedItemIndexes);
                              
                          }];
}
@end
