//
//  SDLoginViewController.m
//  SecretDiary
//
//  Created by Reshma Unnikrishnan on 07/11/13.
//  Copyright (c) 2013 Reshma Unnikrishnan. All rights reserved.
//

#import "SDLoginViewController.h"

@interface SDLoginViewController ()

@end

@implementation SDLoginViewController

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
    // Customize the View
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"squairy_light"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Customize textfields
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.usernameField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setBorderStyle:UITextBorderStyleRoundedRect];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Must use contraints !!!!!!
    
    UIImage *greenButton = [[UIImage imageNamed:@"greenButton"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *greenButtonHighlight = [[UIImage imageNamed:@"greenButtonHighlight"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self.logInView.logInButton setBackgroundImage:greenButton forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:greenButtonHighlight forState:UIControlStateHighlighted];
    
    UIImage *orangeButton = [[UIImage imageNamed:@"orangeButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *orangeButtonHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self.logInView.signUpButton setBackgroundImage:orangeButton forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:orangeButtonHighlight forState:UIControlStateHighlighted];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Facebook Login
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // The permissions requested from the user
    NSArray *permissionsArray = [NSArray arrayWithObjects:
                            @"user_about_me",
                            @"user_relationships",
                            @"user_birthday",
                            @"user_location",
                            @"offline_access",
                            @"email",
                            @"publish_stream",
                            nil];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"User with facebook logged in!");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end
