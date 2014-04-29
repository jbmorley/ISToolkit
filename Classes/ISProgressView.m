//
// Copyright (c) 2013-2014 InSeven Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ISProgressView.h"

@implementation ISProgressView


- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}


- (void)awakeFromNib
{
  [super awakeFromNib];
  self.backgroundColor = [UIColor clearColor];
}


- (void)drawRect:(CGRect)rect
{
  
    // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (self.progress == 1.0f) {
    return;
  }
  
  UIColor *black = [UIColor colorWithRed:0.0
                                   green:0.0f
                                    blue:0.0f
                                   alpha:0.8f];

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
