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

#import "ISBarButtonItem.h"

typedef enum {
  ISArrowDirectionUp = 0,
  ISArrowDirectionDown,
} ISArrowDirection;

@interface ISBarButtonItem () {
  BOOL _animating;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) ISBarButtonItemStyle style;

@end

@implementation ISBarButtonItem


- (id)initWithStyle:(ISBarButtonItemStyle)style
             target:(id)target
             action:(SEL)action
{
  UIImage *image = [self imageForStyle:style
                              rotation:0.0f];
  self = [super initWithImage:image
          landscapeImagePhone:image
                        style:UIBarButtonItemStylePlain
                       target:target
                       action:action];
  if (self) {
    self.style = style;
  }
  return self;
}
     
     
- (void)timerFireMethod:(NSTimer *)timer
{
  self.rotation = (self.rotation + 10) % 360;
  UIImage *image = [self imageForStyle:self.style
                              rotation:self.rotation];
  self.image = image;
  self.landscapeImagePhone = image;

  // Stop the timer if we've completed a revolution and
  // stopAnimation has been set.
  if (!_animating && self.rotation == 0) {
    [self.timer invalidate];
    self.timer = nil;
  }
}


- (void)startAnimating
{
  if (!_animating) {
    _animating = YES;
    
    // Create and start a timer if one isn't already running.
    if (self.timer == nil) {
      self.timer =
      [NSTimer timerWithTimeInterval:0.05
                              target:self
                            selector:@selector(timerFireMethod:)
                            userInfo:nil
                             repeats:YES];
      [[NSRunLoop mainRunLoop] addTimer:self.timer
                                forMode:NSRunLoopCommonModes];
    }
  }
}


- (void)drawArrow:(CGContextRef)context
           center:(CGPoint)center
           radius:(CGFloat)radius
       startAngle:(CGFloat)startAngle
         endAngle:(CGFloat)endAngle
        direction:(ISArrowDirection)direction
           length:(CGFloat)length
{
  // Draw the arc.
  CGContextBeginPath(context);
  CGContextAddArc(context,
                  center.x,
                  center.y,
                  radius,
                  startAngle,
                  endAngle,
                  0);
  CGContextStrokePath(context);
  
  // Draw the arrow.
  CGPoint tip = CGPointMake(center.x + (radius * cos(endAngle)),
                            center.y + (radius * sin(endAngle)));
  CGFloat multiplier = 1.0f;
  if (direction == ISArrowDirectionUp) {
    multiplier = 1.0f;
  } else if (direction == ISArrowDirectionDown) {
    multiplier = - 1.0f;
  }
  
  CGContextMoveToPoint(context,
                       tip.x,
                       tip.y + (multiplier * length));
  CGContextAddLineToPoint(context,
                          tip.x,
                          tip.y);
  CGContextAddLineToPoint(context,
                          tip.x + (multiplier * length),
                          tip.y);
  CGContextStrokePath(context);
}


- (UIImage *)imageForStyle:(ISBarButtonItemStyle)style
                  rotation:(CGFloat)rotation
{
  const CGSize size = CGSizeMake(28.0f, 28.0f);
  const CGFloat increment = M_PI / 180;
  const CGFloat scale = [[UIScreen mainScreen] scale];
  
  CGPoint center = CGPointMake(size.width / 2.0,
                               size.height / 2.0);
  
  UIImage *image = nil;

  // Start the context.
  UIGraphicsBeginImageContextWithOptions(size, NO, scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // Rotate the canvas, saving the state.
  CGContextSaveGState(context);
  CGContextTranslateCTM(context,
                        center.x,
                        center.y);
  CGContextRotateCTM(context,
                     increment * rotation);
  CGContextTranslateCTM(context,
                        -center.x,
                        -center.y);
  
  if (style == ISBarButtonItemStyleRefresh) {
  
    const CGFloat radius = 11.0f;
    const CGFloat length = 6.0f;
    
    [self drawArrow:context
             center:center
             radius:radius
         startAngle:0.0f
           endAngle:M_PI * 0.86f
          direction:ISArrowDirectionUp
             length:length];
    [self drawArrow:context
             center:center
             radius:radius
         startAngle:M_PI
           endAngle:1.86 * M_PI
          direction:ISArrowDirectionDown
             length:length];
    
  } else if (style == ISBarButtonItemStyleClose) {
    
    const CGFloat inset = 4.0f;
    
    CGContextMoveToPoint(context, inset, inset);
    CGContextAddLineToPoint(context, size.width - inset, size.height - inset);
    CGContextStrokePath(context);

    CGContextMoveToPoint(context, size.width - inset, inset);
    CGContextAddLineToPoint(context, inset, size.height - inset);
    CGContextStrokePath(context);
    
  }
  
  // Restore the rotation.
  CGContextRestoreGState(context);
  
  // Generate the image.
  image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}


- (void)stopAnimating
{
  if (_animating) {
    _animating = NO;
    // We do not invalidate the timer here as we want to
    // allow the animation to return to its original orientation
    // before stopping.
  }
}


- (BOOL)isAnimating
{
  return _animating;
}


@end
