//
//  ISProgressButton.m
//  Shows
//
//  Created by Jason Barrie Morley on 05/02/2014.
//  Copyright (c) 2014 InSeven Limited. All rights reserved.
//

#import "ISProgressView.h"

@implementation ISProgressView


- (void)awakeFromNib
{
  [super awakeFromNib];
  self.backgroundColor = [UIColor clearColor];
}


- (void)drawRect:(CGRect)rect
{
  
    // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (self.progress == 1.0) {
    return;
  }
  
  UIColor *black = [UIColor colorWithRed:0.0
                                   green:0.0f
                                    blue:0.0f
                                   alpha:0.9f];

  CGContextSetBlendMode(context,
                        kCGBlendModeColorDodge);
  CGContextSetFillColor(context,
                        CGColorGetComponents([black CGColor]));
  
  // Determine the position of the widget in the view.
  CGFloat size = 50.0f;
  CGRect target = CGRectMake(floorf((self.bounds.size.width - size) / 2),
                             floorf((self.bounds.size.height - size) / 2),
                             size,
                             size);
  
  // Pie.
  if (self.progress > 0.0) {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,
                         (target.size.width / 2) + target.origin.x,
                         (target.size.height / 2) + target.origin.y);
    CGContextAddLineToPoint(context,
                            (target.size.width / 2) + target.origin.x,
                            0);
    CGContextAddArc(context,
                    (target.size.width / 2) + target.origin.x,
                    (target.size.height / 2) + target.origin.y,
                    (target.size.width) / 2,
                    -M_PI_2,
                    (M_PI * 2 * self.progress) - M_PI_2,
                    0);
    CGContextClosePath(context);
    CGContextAddRect(context,
                     self.bounds);
    
    CGContextEOFillPath(context);
  } else {
    CGContextAddRect(context,
                     self.bounds);
    CGContextFillPath(context);
  }
  
  // Fill the path.

}

- (void)setProgress:(CGFloat)progress
{
  if (_progress != progress) {
    _progress = progress;
    [self setNeedsDisplay];
  }
}


@end
