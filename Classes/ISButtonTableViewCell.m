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

#import "ISButtonTableViewCell.h"
#import "ISForm.h"

NSString *const ISButtonStyleNormal = @"ISButtonStyleNormal";
NSString *const ISButtonStylePrimary = @"ISButtonStylePrimary";
NSString *const ISButtonStyleDelete = @"ISButtonStyleDelete";


@implementation ISButtonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:reuseIdentifier];
  if (self) {
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
  }
  return self;
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
  self.textLabel.text = configuration[ISFormTitle];
  NSString *style = configuration[ISFormStyle];
  if ([style isEqualToString:ISButtonStyleNormal]) {
    self.selectedBackgroundView.backgroundColor = [self darkColor:[UIColor whiteColor]];
  } else if ([style isEqualToString:ISButtonStylePrimary]) {
    self.backgroundColor = self.tintColor;
    self.textLabel.textColor = [UIColor whiteColor];
    self.selectedBackgroundView.backgroundColor = [self darkColor:self.tintColor];
  } else if ([style isEqualToString:ISButtonStyleDelete]) {
    self.backgroundColor = [UIColor redColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.selectedBackgroundView.backgroundColor = [self darkColor:[UIColor redColor]];
  }
}


- (void)didSelectItem
{
  [self.settingsDelegate itemDidPerformAction:self];
}


- (UIColor *)darkColor:(UIColor *)color
{
  CGFloat red = 0.0f;
  CGFloat green = 0.0f;
  CGFloat blue = 0.0f;
  CGFloat white = 0.0f;
  CGFloat alpha = 0.0f;
  if ([color getRed:&red
              green:&green
               blue:&blue
              alpha:&alpha]) {
    return [UIColor colorWithRed:MAX(red - 0.2, 0.0)
                           green:MAX(green - 0.2, 0.0)
                            blue:MAX(blue - 0.2, 0.0)
                           alpha:alpha];
  } else if ([color getWhite:&white
                       alpha:&alpha]) {
    return [UIColor colorWithWhite:MAX(white - 0.2, 0.0)
                             alpha:alpha];
  }
  return nil;
}


@end
