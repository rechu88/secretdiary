//
//  SDAllNotesViewController.h
//  SecretDiary
//
//  Created by Reshma Unnikrishnan on 04/11/13.
//  Copyright (c) 2013 Reshma Unnikrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RNFrostedSidebar.h"
#import "MGScrollView.h"

@interface SDAllNotesViewController : UIViewController <RNFrostedSidebarDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property (nonatomic, strong) IBOutlet MGScrollView *diaryEntries;

- (IBAction)menuBtnClicked:(id)sender;
- (void)trashDiaryEntry:(id)sender;

@end
