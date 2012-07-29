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

    NSArray* selected = nil;
    if (self.lastSingleSelected.text.length > 0)
    {
        selected = @[ self.lastSingleSelected.text ];
    }

    self.pop = [[UIXPicklistPopoverController alloc] initWithStrings:arr
                                                         multiSelect:NO
                                                      selectedValues:selected];
    self.pop.picklistPopeverDelegate = self;
        
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

    NSArray* selected = nil;
    if (self.lastMultipleSelected.text.length > 0)
    {
        selected = [self.lastMultipleSelected.text componentsSeparatedByString:@","];
    }
    
    self.pop = [[UIXPicklistPopoverController alloc] initWithStrings:arr
                                                         multiSelect:YES
                                                      selectedValues:selected];
    self.pop.picklistPopeverDelegate = self;
    

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
          selectedValues: (NSArray*) selectedValues
         selectedIndexes:(NSArray*) selectedIndexes
{
    if (!picklistPopoverController.multiSelect)
    {
        self.lastSingleSelected.text = [selectedValues objectAtIndex:0];
    }
    else
    {
        self.lastMultipleSelected.text = [selectedValues componentsJoinedByString:@","];
        NSLog(@"%@",selectedValues);
    }
}

@end
