//
//  ViewController.m
//  AnnoDemo
//
//  Created by Dan Kolov on 5/12/14.
//  Copyright (c) 2014 Europesoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{

    AnnoViewController *annoViewController;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Load Pdf File
    
    NSString *password = @"";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"pdf"];


    assert(filePath != nil);
    
    RoboDocument *document = [RoboDocument withDocumentFilePath:filePath password:password];
    
    if (document != nil) {
        annoViewController = [[AnnoViewController alloc] initWithRoboDocument:document];
        
        annoViewController.delegate = self;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        [self.navigationController pushViewController:annoViewController animated:YES];
        
        
    }

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
    
}


- (void)dismissRoboViewController:(RoboViewController *)viewController {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
