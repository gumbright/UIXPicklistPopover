//
//  ViewController.h
//  uixpopoverpicker
//
//  Created by Guy Umbright on 5/17/12.
//  Copyright (c) 2012 Kickstand Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIXPicklistPopoverController.h"

@interface ViewController : UIViewController <UIXPicklistPopoverControllerDelegate>

@property (nonatomic, strong) UIXPicklistPopoverController* pop;
@property (nonatomic, assign) IBOutlet UILabel* lastSingleSelected;

- (IBAction) simplePicklistPressed:(id) sender;
- (IBAction) multiselectPicklistPressed:(id) sender;

@end
