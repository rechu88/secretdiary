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
    UIImageView *imageView;
    NSMutableArray *exclusions;
    UIFont *regularFont, *boldFont, *italicsFont, *boldItalicFont;
    
    // To store start of image pans
    CGFloat firstX;
    CGFloat firstY;
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
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 1.0);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    // Set text content
    NSData* notes = [NSKeyedArchiver archivedDataWithRootObject:_noteView.attributedText];
    //read the data back in and decode the string
//    NSData* newStringData = [NSData dataWithContentsOfFile:pathToFile];
//    NSAttributedString* newString = [NSKeyedUnarchiver unarchiveObjectWithData:newStringData];

    [newPost setObject:notes forKey:@"notes"];
    [newPost setObject:[NSDate date] forKey:@"date"];
    [newPost setObject:imageFile forKey:@"images"];

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
    imageView = [[UIImageView alloc] initWithImage:selectedImage];
    
    CGPoint cursorPosition = [_noteView caretRectForPosition:_noteView.selectedTextRange.start].origin;
    
    UIBezierPath *imagePath = [UIBezierPath bezierPathWithRect:CGRectMake(cursorPosition.x, cursorPosition.y, EMBED_IMAGE_WIDTH, EMBED_IMAGE_HEIGHT)];
    [imageView setFrame:CGRectMake(cursorPosition.x, cursorPosition.y, EMBED_IMAGE_WIDTH, EMBED_IMAGE_HEIGHT)];
    // Set the tag to the index to add
    imageView.tag = [exclusions count];
    
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapGesture.numberOfTapsRequired = 2;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tapGesture];
    
    // creat and configure the pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    
    // Adding the pan gesture capture
    [imageView addGestureRecognizer:panGestureRecognizer];
    
    exclusions = [NSMutableArray arrayWithArray:_noteView.textContainer.exclusionPaths];
    
    [exclusions addObject:imagePath];
    _noteView.textContainer.exclusionPaths = exclusions;
    [_noteView addSubview:imageView];
    
}

- (void)imageTapped:(UITapGestureRecognizer *)recognizer
{
    UIImageView *movingImage = (UIImageView*)recognizer.view;
    
    [movingImage removeFromSuperview];
    
    if ([exclusions count] >= movingImage.tag) {
        [exclusions removeObjectAtIndex:movingImage.tag];
        _noteView.textContainer.exclusionPaths = exclusions;
    }
}

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    
    if(state == UIGestureRecognizerStateBegan) {
        
        firstX = [[recognizer view] center].x;
        firstY = [[recognizer view] center].y;
    }
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [[recognizer view] setCenter:translatedPoint];
    
    if(state == UIGestureRecognizerStateEnded) {
        
        UIImageView *movingImage = (UIImageView*)recognizer.view;
        
        CGFloat finalX = translatedPoint.x;
        CGFloat finalY = translatedPoint.y;
        
        if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            
            if(finalX < 0) {
                finalX = 0;
            } else if(finalX > 768) {
                finalX = 768;
            }
            
            if(finalY < 0) {
                finalY = 0;
            }   else if(finalY > 1024) {
                finalY = 1024;
            }
        } else {
            if(finalX < 0) {
                finalX = 0;
            } else if(finalX > 1024) {
                finalX = 768;
            }
            
            if(finalY < 0) {
                finalY = 0;
            } else if(finalY > 768) {
                finalY = 1024;
            }
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.35];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [movingImage setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];

        UIBezierPath *imagePath = [UIBezierPath bezierPathWithRect:CGRectMake(finalX - EMBED_IMAGE_WIDTH/2, finalY - EMBED_IMAGE_HEIGHT/2, EMBED_IMAGE_WIDTH, EMBED_IMAGE_HEIGHT)];

        [exclusions setObject:imagePath atIndexedSubscript:movingImage.tag];
        _noteView.textContainer.exclusionPaths = exclusions;
    }
}

@end
