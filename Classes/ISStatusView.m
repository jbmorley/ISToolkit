//
//  ISStatusView.m
//  Shows
//
//  Created by Jason Barrie Morley on 05/02/2014.
//  Copyright (c) 2014 InSeven Limited. All rights reserved.
//

#import "ISStatusView.h"

@interface ISStatusView ()

@property (nonatomic) CGFloat strokeWidth;

@end

@implementation ISStatusView


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.strokeWidth = 1.0f;
  }
  return self;
}


- (void)awakeFromNib
{
  self.backgroundColor = [UIColor clearColor];
  self.strokeWidth = 1.0f;
  self.state = ISStatusViewStatePartial;
}


- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColor(context,
                        CGColorGetComponents([self.tintColor CGColor]));
    CGContextSetStrokeColor(context,
                            CGColorGetComponents([self.tintColor CGColor]));
  
  CGRect target = self.bounds;
  
  if (self.state ==
      ISStatusViewStateIncomplete) {
    
    // Filled circle.
    CGContextAddEllipseInRect(context, target);
    CGContextFillPath(context);
    
  } else if (self.state ==
             ISStatusViewStatePartial) {
    
    // Empty circle.
    CGRect strokeRect =
    CGRectMake(self.strokeWidth / 2,
               self.strokeWidth / 2,
               target.size.width - self.strokeWidth,
               target.size.height - self.strokeWidth);
    CGContextAddEllipseInRect(context, strokeRect);
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextStrokePath(context);
    
    // Half circle.
    CGContextBeginPath(context);
    CGContextAddArc(context,
                    (target.size.width / 2) + target.origin.x,
                    (target.size.height / 2) + target.origin.y,
                    (target.size.width - self.strokeWidth) / 2,
                    -M_PI_2,
                    M_PI_2,
                    0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
  } else if (self.state ==
             ISStatusViewStateComplete) {
    
    // Empty circle.
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    
    CGRect strokeRect =
    CGRectMake(self.strokeWidth / 2,
               self.strokeWidth / 2,
               target.size.width - self.strokeWidth,
               target.size.height - self.strokeWidth);
    CGContextAddEllipseInRect(context, strokeRect);
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextStrokePath(context);
    
  }

}


- (void)setState:(ISStatusViewState)state
{
  if (_state != state) {
    _state = state;
    [self setNeedsDisplay];
  }
}


@end
