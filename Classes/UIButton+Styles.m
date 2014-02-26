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

#import "UIButton+Styles.h"

static NSString *BackgroundDefault = @"ISToolkit.bundle/ButtonDefault.png";
static NSString *BackgroundDelete = @"ISToolkit.bundle/ButtonDelete.png";

@implementation UIButton (Styles)

+ (UIButton *)buttonWithFrame:(CGRect)frame
                        style:(UIButtonStyle)style
{
  UIButton *button = nil;
  if (style == UIButtonStyleDefault) {
    button = [[UIButton alloc] initWithFrame:frame
                                       style:style];
  } else if (style == UIButtonStyleDelete) {
    button = [[UIButton alloc] initWithFrame:frame
                                       style:style];
  } else if (style == UIButtonStyleRoundedRect) {
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
  }
  
  return button;
}

- (id)initWithFrame:(CGRect)frame
              style:(UIButtonStyle)style
{
  self = [super initWithFrame:frame];
  if (self) {
    
    if (style == UIButtonStyleDefault) {
      [self setBackgroundImage:[[UIImage imageNamed:BackgroundDefault]
                                stretchableImageWithLeftCapWidth:10.0f
                                topCapHeight:0.0f]
                      forState:UIControlStateNormal];
    } else if (style == UIButtonStyleDelete) {
      [self setBackgroundImage:[[UIImage imageNamed:BackgroundDelete]
                                stretchableImageWithLeftCapWidth:10.0f
                                topCapHeight:0.0f]
                      forState:UIControlStateNormal];
    } else if (style == UIButtonStyleRoundedRect) {
      NSAssert(NO, @"Invalid type for constructor.");
    }
    
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.shadowColor = [UIColor lightGrayColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.adjustsImageWhenHighlighted = YES;

  }
  return self;
}

@end
