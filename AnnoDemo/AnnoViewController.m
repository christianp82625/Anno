//
//  AnnoViewController.m
//  AnnoDemo
//
//  Created by Dan Kolov on 5/12/14.
//  Copyright (c) 2014 Europesoft. All rights reserved.
//

#define ANNOTATION_WIDTH 20
#define ANNOTATION_HEIGHT 20

#define MSG_WIDTH 150
#define MSG_HEIGHT 100

#define LABEL_HEIGHT 30

#define CLOSE_WIDTH 30
#define CLOSE_HEIGHT 30



#import "AnnoViewController.h"

@interface AnnoViewController ()

@end

@implementation AnnoViewController

// Annotaion Image Collection
NSMutableDictionary *annotations;
NSMutableDictionary *msgs;


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
    // Do any additional setup after loading the view.
    
    // attach long press gesture to AnnoViewController
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    
    lpgr.minimumPressDuration = 0.5f; //seconds
    lpgr.delegate = self;
    [theScrollView addGestureRecognizer:lpgr];
    
    annotations = [[NSMutableDictionary alloc] init];
    
    msgs = [[NSMutableDictionary alloc] init];
    [theScrollView setMaximumZoomScale:0.0];
    [theScrollView setMinimumZoomScale:0.0];
    theScrollView.panGestureRecognizer.enabled = NO;
    theScrollView.pinchGestureRecognizer.enabled = NO;
    
    
    // Add single tap guesture to hide all exising sticky messages
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    singleTapOne.delegate = self;
    
    [theScrollView addGestureRecognizer:singleTapOne];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// long Prress event function

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        return;
    }
    
    
    NSString* key = [NSString stringWithFormat:@"%i", document.currentPage.intValue];
    
    RoboContentView *contentView = contentViews[key];
    
   // contentView.theContentViewImagePDF=nil;
    
    NSLog(@"pdf-----> frame %@", NSStringFromCGRect(contentView.frame));
    NSLog(@"pdf-----> actual %@", NSStringFromCGRect(contentView.theContentViewImagePDF.frame));
    
    //[contentView pageContentLoadingComplete:pageBarImage rightSide:rightSide zoomed:zoomed];
    
    CGPoint p = [gestureRecognizer locationInView:theScrollView];
    
    CGRect aRect=CGRectMake(contentView.frame.origin.x+contentView.theContentViewImagePDF.frame.origin.x,contentView.theContentViewImagePDF.frame.origin.y,
                            contentView.theContentViewImagePDF.frame.size.width,contentView.theContentViewImagePDF.frame.size.height);
    
    
    if ( CGRectContainsPoint(aRect, p ) ) {
        NSLog(@"Inside");
        
        UIImage *image = [UIImage imageNamed:@"annotation.png" ];
        UIImageView *annotationView = [[UIImageView alloc] initWithImage:image];
        

        
        [annotationView setFrame:CGRectMake(p.x-ANNOTATION_WIDTH/2, p.y-ANNOTATION_HEIGHT/2, ANNOTATION_WIDTH, ANNOTATION_HEIGHT)];
        
        
        if (annotations[key]== nil){
            annotations[key]=[[NSMutableArray alloc] init];
        }
        NSMutableArray *pageAnnotation=(NSMutableArray*) annotations[key];
        
        /* Tap gesture Recognizer for AnnotaionImageView  */
        annotationView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleAnnotation:)];
        
        pgr.numberOfTouchesRequired = 1;
        pgr.numberOfTapsRequired = 1;
       // pgr.delegate = self;
        
        annotationView.tag=[pageAnnotation count]; //specify tag
        [pageAnnotation addObject:annotationView];
        [annotationView addGestureRecognizer:pgr];
        
        
        [theScrollView addSubview:annotationView];
        /* add annotation oject into array */
        

    } else {
        NSLog(@"Outside");
    }
    
    NSLog(@"%@", NSStringFromCGPoint(p));
    NSLog(@"%d", document.currentPage.intValue);
}


-(void)handleAnnotation:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSString* key = [NSString stringWithFormat:@"%i", document.currentPage.intValue];
    
    if (msgs[key]== nil){

        msgs[key] = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *pageMsg=(NSMutableDictionary*) msgs[key];
    
    UIImageView *annotationView =(UIImageView *)gestureRecognizer.view;
    
    /*
     if Msgview for annotaion image is already assigned, skip
     */
    
    NSString* tagKey = [NSString stringWithFormat:@"%i", annotationView.tag];
    
    if (pageMsg[tagKey]!=nil){
   
        UIView *msgView=(UIView*)pageMsg[tagKey];
        
        
        [msgView setHidden:NO];

        
        return;
    }
        
    
    //create textbox area
    
    NSLog(@"x %f : %f", annotationView.frame.origin.x,annotationView.frame.origin.y);
    
    UIView* msgView = [[UIView alloc] initWithFrame:CGRectMake(annotationView.frame.origin.x+50, annotationView.frame.origin.y-25, MSG_WIDTH, MSG_HEIGHT+LABEL_HEIGHT)];
    
    
    UITextView* text = [[UITextView alloc] initWithFrame:CGRectMake(0, LABEL_HEIGHT, MSG_WIDTH, MSG_HEIGHT)];
    
    text.autocorrectionType = FALSE;
    text.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MSG_WIDTH-CLOSE_WIDTH, LABEL_HEIGHT)];
    
    [label setBackgroundColor:[UIColor whiteColor]];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    label.text= [dateFormat stringFromDate:date];
    
    UIButton *closeBtn=[[UIButton alloc] initWithFrame:CGRectMake(MSG_WIDTH-CLOSE_WIDTH, 0, CLOSE_WIDTH, CLOSE_HEIGHT)];
    UIImage *bntImage = [UIImage imageNamed:@"close.png" ];
    
    [closeBtn setImage:bntImage forState:UIControlStateNormal];
    
    [text setBackgroundColor:[UIColor colorWithRed:254.0f/255.0f green:255.0f/255.0f blue:213.0f/255.0f alpha:1]];
    
    // Add tap geusture to close Button
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(closeAnnotation:)];
    
    gesture.numberOfTouchesRequired = 1;
    gesture.numberOfTapsRequired = 1;
    // pgr.delegate = self;
    
//    [closeBtn addObject:annotationView];
    
    
    closeBtn.tag=annotationView.tag; // make close button tag same as annotaionView Tag so that we can reference it later easily
    
    [closeBtn addGestureRecognizer:gesture];
    
    [msgView addSubview:text];
    [msgView addSubview:closeBtn];
    [msgView addSubview:label];
    
    pageMsg[tagKey]=msgView;
    
    [theScrollView addSubview:msgView];
    
}

-(void)closeAnnotation:(UITapGestureRecognizer *)gestureRecognizer{
    UIButton *closeBtn =(UIButton *)gestureRecognizer.view;
    
    NSString* key = [NSString stringWithFormat:@"%i", document.currentPage.intValue];

    NSMutableDictionary *pageMsg=(NSMutableDictionary*) msgs[key];

    NSString* tagKey = [NSString stringWithFormat:@"%i", closeBtn.tag];
    UIView *msgView=(UIView*)pageMsg[tagKey];
    
    //animation code
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [msgView.layer addAnimation:animation forKey:nil];

    
    [msgView setHidden:YES];
    
    [self.view endEditing:YES];
//    [msgView removeFromSuperview];

//    [pageMsg setValue:nil forKey:tagKey];

}

- (void)pageContentLoadingComplete:(int)page pageBarImage:(UIImage *)pageBarImage rightSide:(BOOL)rightSide zoomed:(BOOL)zoomed {
    [super pageContentLoadingComplete:page pageBarImage:pageBarImage rightSide:rightSide zoomed:zoomed];
    
    
    [self showAnnotation:page];
}

// display annotation
- (void)showAnnotation:(int)page{
    //code for loading annotaiton images
    
    NSString* key = [NSString stringWithFormat:@"%i", page];
    
    NSMutableArray *pageAnnotation=(NSMutableArray*) annotations[key];
    
    for (UIImageView* annotationView in pageAnnotation) {
        [theScrollView addSubview:annotationView];
    }
    
    NSMutableDictionary *pageMsg=(NSMutableDictionary*) msgs[key];
    
    for (NSString* tagKey in pageMsg) {
        UIView* msgView=(UIView*)[pageMsg objectForKey:tagKey];
        [theScrollView addSubview:msgView];
    }
    
    
}

//code for loading annotaiton images

- (void)openPage:(int)page {
    [super openPage:page];
    
    [self showAnnotation:page];
    
}

// hide all sticky messages
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    [super handleSingleTap:recognizer];
    
    NSString* key = [NSString stringWithFormat:@"%i", document.currentPage.intValue];
    
    NSMutableDictionary *pageMsg=(NSMutableDictionary*) msgs[key];
    
    for (NSString* tagKey in pageMsg) {
        UIView* msgView=(UIView*)[pageMsg objectForKey:tagKey];
        
        //animation code
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [msgView.layer addAnimation:animation forKey:nil];
        
        [msgView setHidden:YES ];
    }
    
    [self.view endEditing:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
