//
//  SDSignupViewController.m
//  SecretDiary
//
//  Created by Reshma Unnikrishnan on 07/11/13.
//  Copyright (c) 2013 Reshma Unnikrishnan. All rights reserved.
//

#import "SDSignupViewController.h"

@interface SDSignupViewController ()

@end

@implementation SDSignupViewController

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
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"squairy_light"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]]];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Customize textfields
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.usernameField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setBorderStyle:UITextBorderStyleRoundedRect];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    UIImage *orangeButton = [[UIImage imageNamed:@"orangeButton.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *orangeButtonHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self.signUpView.signUpButton setBackgroundImage:orangeButton forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:orangeButtonHighlight forState:UIControlStateHighlighted];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
