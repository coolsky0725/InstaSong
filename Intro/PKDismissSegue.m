//
//  PKDismissSegue.m
//  Peek
//
//  Created by Robert Bastian on 2014-03-16.
//  Copyright (c) 2014 Peek Inc. All rights reserved.
//

#import "PKDismissSegue.h"

@implementation PKDismissSegue

- (void)perform
{
    UIViewController *source = self.sourceViewController;
    UIViewController *destination = self.destinationViewController;
    UIView *sourceView = source.view;
    UIView *destinationView = destination.view;

    // Create a UIImageView with the contents of the source
    UIGraphicsBeginImageContext(sourceView.bounds.size);
    [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:sourceImage];


    CGPoint sourceViewFinalCenter = CGPointMake(sourceView.center.x, sourceView.center.y+sourceView.frame.size.height);
    [destinationView addSubview:sourceImageView];

    [UIView animateWithDuration:0.3f
                     animations:^{
                         sourceImageView.center = sourceViewFinalCenter;
                     }
                     completion:^(BOOL finished){
                         [sourceImageView removeFromSuperview];
                     }];
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:NULL];


}

@end
