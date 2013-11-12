//
//  SDAllNotesViewController.m
//  SecretDiary
//
//  Created by Reshma Unnikrishnan on 04/11/13.
//  Copyright (c) 2013 Reshma Unnikrishnan. All rights reserved.
//

#import "SDAllNotesViewController.h"
#import "SDAddNotesViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "SDLoginViewController.h"
#import "SDSignupViewController.h"

#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "MGButton.h"

#import <Parse/Parse.h>

#define OPTION_TAG  3
#define SECTION_TAG 4
#define TRASHME_TAG 5
#define LOCKME_TAG  6
#define SHOWME_TAG  7

#define MENU_ITEM_PROFILE   0
#define MENU_ITEM_PLUS      1
#define MENU_ITEM_GEAR      2
#define MENU_ITEM_EXIT      3

#define DIARY_BUTTON_SIZE (CGSize){30, 30}
#define DIARY_BUTTON_BCK_COLOR [UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:0.3f];

@implementation SDAllNotesViewController {
    MGBox *tablesGrid;
    BOOL phone;
    UIImage *profileImage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Beautify The title
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Lato-Light" size:24.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.text = @"Secret Diary";
    self.navigationItem.titleView = label;
    
    // Default Appearances
    
    [[UIBarButtonItem appearance]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont fontWithName:@"Lato-Light" size:16.0f],NSFontAttributeName, nil]
     forState:UIControlStateNormal];
    
    
	// Do any additional setup after loading the view.
    self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];
    
    // Create a query
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Entries"];
    
    // Follow relationship
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray * objects = objects;
        }
    }];

    
    // iPhone or iPad?
    UIDevice *device = UIDevice.currentDevice;
    phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    
    [self.diaryEntries setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.9 alpha:0.2f]];
    self.diaryEntries.contentLayoutMode = MGLayoutGridStyle;
    self.diaryEntries.bottomPadding = 8;
    self.diaryEntries.translatesAutoresizingMaskIntoConstraints = FALSE;
    
    tablesGrid = MGBox.box;
    tablesGrid.contentLayoutMode = MGLayoutTableStyle;
    [self.diaryEntries.boxes addObject:tablesGrid];
    
    // add ten 100x100 boxes, with 10pt top and left margins
    for (int i = 0; i < 10; i++) {
        int start = i+1;
        MGBox *container = MGBox.box;
        container.sizingMode = MGResizingShrinkWrap;
        container.tag = start * 10;
        
        [tablesGrid.boxes addObject:container];
        
        MGBox *options = MGBox.box;
        [container.boxes addObject:options];
        options.tag = OPTION_TAG;
        
        options.leftMargin = 10;
        options.topMargin = 10;

        MGButton *trashMe = [MGButton buttonWithType:UIButtonTypeCustom];
        [trashMe setImage:[UIImage imageNamed:@"small-trash"] forState:UIControlStateNormal];
        trashMe.backgroundColor = DIARY_BUTTON_BCK_COLOR;
        trashMe.size = DIARY_BUTTON_SIZE;
        trashMe.layer.cornerRadius = 10;
        trashMe.clipsToBounds = YES;
        [options.boxes addObject:trashMe];
        trashMe.tag = TRASHME_TAG + (start * 10);
        
        MGButton *lockMe = [MGButton buttonWithType:UIButtonTypeCustom];
        [lockMe setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
        lockMe.backgroundColor = DIARY_BUTTON_BCK_COLOR;
        lockMe.size = DIARY_BUTTON_SIZE;
        lockMe.topMargin = 15;
        lockMe.layer.cornerRadius = 10;
        lockMe.clipsToBounds = YES;
        [options.boxes addObject:lockMe];
        lockMe.tag = LOCKME_TAG + (start * 10);
        
        MGButton *showMe = [MGButton buttonWithType:UIButtonTypeCustom];
        [showMe setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        showMe.backgroundColor = DIARY_BUTTON_BCK_COLOR;
        showMe.size = DIARY_BUTTON_SIZE;
        showMe.topMargin = 15;
        showMe.layer.cornerRadius = 10;
        showMe.clipsToBounds = YES;
        [options.boxes addObject:showMe];
        showMe.tag = SHOWME_TAG + (start * 10);
        
        MGTableBoxStyled *section = MGTableBoxStyled.box;
        section.sizingMode = MGResizingShrinkWrap;
        section.tag = SECTION_TAG;
        
        options.attachedTo = section;
        
        // a header row
        MGLineStyled *header = MGLineStyled.line;
        header.multilineLeft = @"My First Table";
        
        header.leftPadding = header.rightPadding = 16;
        [section.topLines addObject:header];
        
        // a string with Mush markup
        MGLineStyled *row2 = MGLineStyled.line;
        row2.multilineLeft = @"This row has **bold** text, //italics// text, __underlined__ text, "
        "and some `monospaced` text. The text will span more than one line, and the row will "
        "automatically adjust its height to fit.|mush";
        row2.minHeight = 40;
        
        [section.topLines addObject:row2];
        
        [container.boxes addObject:section];

        section.onTap = ^{
            [self closeContainer:(start * 10)];
        };
        
        [trashMe addTarget:self action:@selector(trashDiaryEntry:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [tablesGrid layout];
    
    [self updateFBProfilePic];
}

// Update the facebook profile pic
- (void)updateFBProfilePic
{
    // Update the user picture if Facebook
    profileImage = [UIImage imageNamed:@"person"];
    if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,picture,email,id";
        
        FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
        
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary *userData = (NSDictionary *)result;
                NSDictionary *dicFacebookPicture = [userData objectForKey:@"picture"];
                NSLog(@"%@", dicFacebookPicture);
                NSDictionary *dicFacebookData = [dicFacebookPicture objectForKey:@"data"];
                NSString *sUrlPic= [dicFacebookData objectForKey:@"url"];
                profileImage = [UIImage imageWithData:
                                [NSData dataWithContentsOfURL:
                                 [NSURL URLWithString: sUrlPic]]];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self checkLogin];
    
    [self.diaryEntries layoutWithSpeed:0.6 completion:nil];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuBtnClicked:(id)sender {
    NSArray *images = @[
                        profileImage,
                        [UIImage imageNamed:@"plus"],
                        [UIImage imageNamed:@"gear"],
                        [UIImage imageNamed:@"exit"]
                        ];
    
    NSArray *colors = @[
                        [UIColor colorWithRed:140/255.f green:109/255.f blue:234/255.f alpha:1],
                        [UIColor colorWithRed:240/255.f green:159/255.f blue:254/255.f alpha:1],
                        [UIColor colorWithRed:255/255.f green:137/255.f blue:167/255.f alpha:1],
                        [UIColor colorWithRed:126/255.f green:242/255.f blue:195/255.f alpha:1]
                        ];
    
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:self.optionIndices borderColors:colors];
    //    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    callout.delegate = self;
    //    callout.showFromRight = YES;
    [callout show];
}

#pragma Delegate Targets for FrostedSidebar

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    [sidebar dismiss];
    
    switch (index) {
        case MENU_ITEM_EXIT:
            [self logoutUser];
            break;
            
        default:
            break;
    }
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index {
    if (itemEnabled) {
        [self.optionIndices addIndex:index];
    }
    else {
        [self.optionIndices removeIndex:index];
    }
}

#pragma mark - Rotation and resizing

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    // relayout the sections
    [self.diaryEntries layoutWithSpeed:duration completion:nil];
    
    if (orient == UIInterfaceOrientationLandscapeRight||orient == UIInterfaceOrientationLandscapeLeft) {
    }

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orient {
    NSLog(@"Fron Orientation changed");
}

#pragma mark - Event Listeners for Individual Diary Entries

- (void)closeContainer:(int)thisTag {
    MGBox *container = (MGBox*)[tablesGrid viewWithTag:thisTag];
    
    NSArray *subViews = [container subviews];
    MGBox *options = [subViews objectAtIndex:0];
    MGTableBoxStyled *section = [subViews objectAtIndex:1];
    
    if (section.isTapped) {
        options.leftMargin = 10;
        section.leftMargin = 10;
        section.isTapped = false;
    } else {
        options.leftMargin = -40;
        section.leftMargin = 50;
        section.isTapped = true;
    }

    [section layoutWithSpeed:0.3 completion:nil];
    [container layoutWithSpeed:0.3 completion:nil];
    [tablesGrid layoutWithSpeed:0.3 completion:nil];
    
    [self.diaryEntries layoutWithSpeed:1 completion:nil];
}

- (void)trashDiaryEntry:(id)sender {
    int thisTag = ((MGButton*)sender).tag;
    thisTag = thisTag - TRASHME_TAG;
    [self closeContainer:thisTag];
}

#pragma Login Methods

// Check Login
- (void)checkLogin {
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        SDLoginViewController *logInViewController = [[SDLoginViewController alloc] init];
        logInViewController.fields =    PFLogInFieldsUsernameAndPassword |
                                        PFLogInFieldsLogInButton |
                                        PFLogInFieldsSignUpButton |
                                        PFLogInFieldsPasswordForgotten |
                                        PFLogInFieldsFacebook;
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        SDSignupViewController *signUpViewController = [[SDSignupViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        [signUpViewController setFields:    PFSignUpFieldsDefault];
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

// Logout
- (void)logoutUser {
    [PFUser logOut];
    
    // Show the modal then !
    [self checkLogin];
}

// Validate Login
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// After Login
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Failed to Login
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Signup Begin
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// After Signup
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
}

// Failed Signup
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

@end
