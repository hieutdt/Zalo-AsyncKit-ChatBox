//
//  UIImage+Additions.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import "UIImage+Additions.h"

@implementation UIImage (Additions)

- (UIImage *)makeCircularImageWithSize:(CGSize)size {
  CGRect circleRect = (CGRect) {CGPointZero, size};
  UIGraphicsBeginImageContextWithOptions(circleRect.size, NO, 0);

  UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
  [circle addClip];

  [self drawInRect:circleRect];
    
  UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  return roundedImage;
}

+ (CGSize)sizeOfImageFromUrl:(NSString *)urlString {
    NSMutableString *imageURL = [NSMutableString stringWithFormat:@"%@", urlString];

    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL URLWithString:imageURL], NULL);
    NSDictionary* imageHeader = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    
    NSLog(@"Image header %@",imageHeader);
    NSLog(@"PixelHeight %@",[imageHeader objectForKey:@"PixelHeight"]);
    NSLog(@"PixelWidth %@", [imageHeader objectForKey:@"PixelWidth"]);
    
    CGFloat width = [[imageHeader objectForKey:@"PixelWidth"] doubleValue];
    CGFloat height = [[imageHeader objectForKey:@"PixelHeight"] doubleValue];
    
    return CGSizeMake(width, height);
}

@end

