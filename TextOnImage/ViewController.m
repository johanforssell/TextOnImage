//
//  ViewController.m
//  TextOnImage
//
//  Created by Johan Forssell on 20/08/14.
//  Copyright (c) 2014 People That Make. All rights reserved.
//

#import "ViewController.h"

#import <FXColorSpace/FXColorSpace.h>


@interface ViewController ()
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, assign) CGSize    shadowSize;
@property (nonatomic, assign) CGFloat   brightnessThreshold;
@property (nonatomic, assign) NSInteger numberOfImages;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.brightnessThreshold  = 1.5;
    
    
    self.shadowSize = CGSizeMake(0.5, 1.0);

    
    self.numberOfImages = 8;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self tapAction:nil];
}




- (IBAction)tapAction:(id)sender {
    UIImage *nextImage = [self nextImage];
    
    CGFloat crop_h_inset = nextImage.size.height * 0.45;
    crop_h_inset = crop_h_inset > 50 ? 50 : crop_h_inset; // limit to max 50px height
    
    CGRect image_rect = CGRectMake(0, 0, nextImage.size.width, nextImage.size.height);
    CGRect inset_rect = CGRectInset(image_rect, 0, crop_h_inset);
    UIImage *inset_image = [self cropImage:nextImage rect:inset_rect];
    [self imageLuminosity:inset_image];
    
    self.imageView.image = nextImage;
}



- (UIImage *)nextImage
{
    self.counter = ((self.counter +1) %self.numberOfImages);
    NSString *name = [NSString stringWithFormat:@"%d", (int)self.counter+1];
    return [UIImage imageNamed:name];
}



- (UIImage *)cropImage:(UIImage *)image rect:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x * image.scale,
                      rect.origin.y * image.scale,
                      rect.size.width * image.scale,
                      rect.size.height * image.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}



- (void)imageLuminosity:(UIImage *)image
{
    double brightnessSum = 0;
    for (UIColor* color in image) {
        brightnessSum += color.FX_hsba.component.brightness;
    }
    double averageImageBrightness = brightnessSum / (image.size.width*image.size.height);
    
    [self updateBrightnessLabel:averageImageBrightness];

    if (averageImageBrightness < self.brightnessThreshold) {
        [self whiteTextWithBlackShadow];
    }
    else {
        [self blackTextWithWhiteShadow];
    }
}

#pragma mark - text styling

- (void)whiteTextWithBlackShadow
{
    NSShadow * shadow = [NSShadow new];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = self.shadowSize;
    
    NSDictionary * textAttributes =
    @{
      NSForegroundColorAttributeName : [UIColor whiteColor],
      NSShadowAttributeName          : shadow
      };

    self.label.attributedText = [[NSAttributedString alloc] initWithString:self.label.text attributes:textAttributes];
}

- (void)blackTextWithWhiteShadow
{
    NSShadow * shadow = [NSShadow new];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = self.shadowSize;
    
    NSDictionary * textAttributes =
    @{
      NSForegroundColorAttributeName : [UIColor blackColor],
      NSShadowAttributeName          : shadow
      };
    
    self.label.attributedText = [[NSAttributedString alloc] initWithString:self.label.text attributes:textAttributes];
}

- (void)updateBrightnessLabel:(double)brightness
{
    self.brightnessLabel.text = [NSString stringWithFormat:@"Brightness: %1.3f", brightness];
}

@end
