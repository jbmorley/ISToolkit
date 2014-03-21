//
// Copyright (c) 2013 InSeven Limited.
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
  
  CGColorRef color = [self.tintColor CGColor];
  CGContextSetFillColorWithColor(context, color);
  CGContextSetStrokeColorWithColor(context, color);
  
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
    
    if (self.showsWhenComplete) {
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

}


- (void)setState:(ISStatusViewState)state
{
  if (_state != state) {
    _state = state;
    [self setNeedsDisplay];
  }
}


- (void)setShowsWhenComplete:(BOOL)showsWhenComplete
{
  if (_showsWhenComplete != showsWhenComplete) {
    _showsWhenComplete = showsWhenComplete;
    [self setNeedsDisplay];
  }
}


- (void)tintColorDidChange
{
  [super tintColorDidChange];
  [self setNeedsDisplay];
}


@end
