//
//  ViewController.m
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize pop;
@synthesize  lastSingleSelected;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction) simplePicklistPressed:(UIButton*) sender
{
    NSArray* arr = [NSArray arrayWithObjects:@"Alpha",@"Beta",@"Gamma",@"Omega", nil];
    self.pop = [UIXPicklistPopoverController picklistPopoverWithStrings:arr];
    self.pop.picklistPopeverDelegate = self;
    [self.pop setSelectedLabel:self.lastSingleSelected.text];
    
    [self.pop presentPopoverFromRect:sender.frame 
                              inView:self.view 
            permittedArrowDirections:UIPopoverArrowDirectionAny 
                            animated:YES];
}


- (IBAction) multiselectPicklistPressed:(UIButton*) sender
{
    NSArray* arr = [NSArray arrayWithObjects:@"Alpha",@"Beta",@"Gamma",@"Omega",@"Toaster",@"Poptart",@"Watermelon",@"Fruit bat",@"Breakfast Cereal",
                    @"Llamas",@"Very small rocks",@"GoldenTablets",@"Chicken wire",@"Duck Table",@"Pigeon Cable",
                    @"Loose women",@"Evangelicals",@"PC",@"Mac",@"iOS",@"Android",@"Weasel",@"Squirrel",@"Chipmumk",@"Otter",@"Ferret",@"House cat",@"Bibo",@"Lucky Boy",
                    @"Batz Maru",@"Godzilla",@"Rodan",@"Ghidra",@"Ren",@"Stimpy",nil];
    self.pop = [UIXPicklistPopoverController picklistPopoverWithStrings:arr];
    self.pop.multiSelect = YES;
    self.pop.picklistPopeverDelegate = self;
    [self.pop setSelectedLabel:@"GoldenTablets"];
    [self.pop setSelectedLabel:@"iOS"];
    [self.pop setSelectedLabel:@"Otter"];
    [self.pop setSelectedLabel:@"Godzilla"];
    [self.pop setSelectedLabel:@"Bibo"];
    [self.pop setSelectedLabel:@"Android"];
    
    [self.pop presentPopoverFromRect:sender.frame 
                              inView:self.view 
            permittedArrowDirections:UIPopoverArrowDirectionAny 
                            animated:YES];
}


- (void) picklistPopover:(UIXPicklistPopoverController*) picklistPopoverController
           selectedValue:(NSString*) selectedValue 
                 atIndex:(NSInteger) selectedIndex
{
    self.lastSingleSelected.text = selectedValue;
    
    [picklistPopoverController dismissPopoverAnimated:YES];
}

- (void) picklistPopoverDismissed:(UIXPicklistPopoverController *)picklistPopoverController
{
    self.pop = nil;
}

- (void) picklistPopover:(UIXPicklistPopoverController *)picklistPopoverController 
       multiSelectValues: (NSArray*) selectedValues
         selectedIndexes:(NSArray*) selectedIndexes
{
    NSLog(@"%@",selectedValues);
}

@end
