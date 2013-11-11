//
//  SDAddNotesViewController.m
//  SecretDiary
//
//  Created by Reshma Unnikrishnan on 06/11/13.
//  Copyright (c) 2013 Reshma Unnikrishnan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SDAddNotesViewController.h"

#define EMBED_IMAGE_WIDTH   80
#define EMBED_IMAGE_HEIGHT  80

#define BOLD_BUTTON_TAG         10
#define ITALICS_BUTTON_TAG      20
#define UNDERLINE_BUTTON_TAG    30

@interface SDAddNotesViewController ()
{
//    UIImagePickerController *imagePickerController;
    UIImage *selectedImage;
    
    BOOL boldSet, italicsSet, underlineSet;
    
    UIFont *regularFont, *boldFont, *italicsFont, *boldItalicFont;
}

@end

@implementation SDAddNotesViewController

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
    
    boldSet = italicsSet = underlineSet = false;
    
    self.navigationItem.rightBarButtonItem = _addPhotos;
    
    regularFont = [UIFont fontWithName:@"Lato-Light" size:19];
    boldFont    = [UIFont fontWithName:@"Lato-Bold" size:19];
    italicsFont = [UIFont fontWithName:@"Lato-LightItalic" size:19];
    boldItalicFont = [UIFont fontWithName:@"Lato-BoldItalic" size:19];
    
    
    _noteView.font = regularFont;
//    _noteView.text = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
    _noteView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self resignFirstResponder];
}

-(IBAction)addDataToStorage:(id)sender
{
    PFObject *newPost = [PFObject objectWithClassName:@"Entries"];
    
    // Set text content
    NSData* notes = [NSKeyedArchiver archivedDataWithRootObject:_noteView.attributedText];
    //read the data back in and decode the string
//    NSData* newStringData = [NSData dataWithContentsOfFile:pathToFile];
//    NSAttributedString* newString = [NSKeyedUnarchiver unarchiveObjectWithData:newStringData];

    [newPost setObject:notes forKey:@"notes"];
    [newPost setObject:[NSDate date] forKey:@"date"];

    // Relation with User
    [newPost setObject:[PFUser currentUser] forKey:@"author"];
    
    // Save the new post
    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Dismiss the NewPostViewController and show the BlogTableViewController
            return;
        
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error Saving"
                                        message:error.description
                                       delegate:nil
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] show];
        }
    }];
}

-(IBAction)cancelEntry:(id)sender
{
    NSLog(@"%@", _noteView.attributedText);
    [self.navigationController popViewControllerAnimated:YES];
}

// To Make the bold, italic and underline button have the toggle functionality
-(IBAction)toggleForType:(id)sender
{
    UIButton *theButton = (UIButton*)sender;
    [theButton setAlpha:(theButton.selected ? 0.2 : 1.0)];
    
    switch (theButton.tag) {
        case 10:
            boldSet = !theButton.selected;
            break;
        case 20:
            italicsSet = !theButton.selected;
            break;
        case 30:
            underlineSet = !theButton.selected;
            break;
        default:
            break;
    }
    
    theButton.selected = !theButton.selected;
}

#pragma Delegate Callback for NoteView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // to update NoteView
    [_noteView setNeedsDisplay];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Backspace Detection
    if ([text isEqualToString:@""]) {
        return YES;
    }
    
    NSDictionary *fontAttr;
    
    if (boldSet || italicsSet) {
        if (boldSet) {
            fontAttr = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
        }
        if (italicsSet) {
            fontAttr = [NSDictionary dictionaryWithObject:italicsFont forKey:NSFontAttributeName];
        }
        if (boldSet && italicsSet) {
            fontAttr = [NSDictionary dictionaryWithObject:boldItalicFont forKey:NSFontAttributeName];
        }
    } else {
        fontAttr = [NSDictionary dictionaryWithObject:regularFont forKey:NSFontAttributeName];
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:text attributes:fontAttr];
    NSMutableAttributedString *textViewText = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
    [textViewText appendAttributedString:attributedText];
    textView.attributedText = textViewText;
    
    return NO;
}

-(IBAction)addPhotos:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Face for Perform Dance step"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int i = buttonIndex;
    switch(i)
    {
        case 0:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{}];
        }
            break;
        case 1:
        {
           UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:^{}];
        }
        default:
            // Do Nothing.........
            break;
    }
}

#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Picking Image from Camera/ Library
    [picker dismissViewControllerAnimated:YES completion:^{}];
    selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (!selectedImage)
    {
        return;
    }
    
    // Adjusting Image Orientation
    NSData *data = UIImagePNGRepresentation(selectedImage);
    UIImage *tmp = [UIImage imageWithData:data];
    UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
                                         scale:selectedImage.scale
                                   orientation:selectedImage.imageOrientation];
    selectedImage = fixed;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:selectedImage];
    
    CGPoint cursorPosition = [_noteView caretRectForPosition:_noteView.selectedTextRange.start].origin;
    
    
    UIBezierPath *imagePath = [UIBezierPath bezierPathWithRect:CGRectMake(cursorPosition.x, cursorPosition.y, EMBED_IMAGE_WIDTH, EMBED_IMAGE_HEIGHT)];
    [imageView setFrame:CGRectMake(cursorPosition.x, cursorPosition.y, EMBED_IMAGE_WIDTH, EMBED_IMAGE_HEIGHT)];
    
    NSMutableArray *exclusions = [NSMutableArray arrayWithArray:_noteView.textContainer.exclusionPaths];
    
    [exclusions addObject:imagePath];
    _noteView.textContainer.exclusionPaths = exclusions;
    [_noteView addSubview:imageView];
    
}

@end
