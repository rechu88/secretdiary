//
//  SDAddNotesViewController.h
//  SecretDiary
//
//  Created by Reshma Unnikrishnan on 06/11/13.
//  Copyright (c) 2013 Reshma Unnikrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NoteView.h"

@interface SDAddNotesViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate, UIScrollViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet NoteView *noteView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addPhotos;

-(IBAction)addDataToStorage:(id)sender;
-(IBAction)addPhotos:(id)sender;
-(IBAction)cancelEntry:(id)sender;
-(IBAction)toggleForType:(id)sender;
@end
