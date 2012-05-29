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
    
    [self.pop presentPopoverFromRect:sender.frame 
                              inView:self.view 
            permittedArrowDirections:UIPopoverArrowDirectionAny 
                            animated:YES];
}


- (IBAction) multiselectPicklistPressed:(UIButton*) sender
{
    NSArray* arr = [NSArray arrayWithObjects:@"Alpha",@"Beta",@"Gamma",@"Omega", nil];
    self.pop = [UIXPicklistPopoverController picklistPopoverWithStrings:arr];
    self.pop.multiSelect = YES;
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
    [picklistPopoverController dismissPopoverAnimated:YES];
//    self.pop = nil;
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
