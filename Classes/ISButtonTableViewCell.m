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

#import "ISButtonTableViewCell.h"
#import "ISForm.h"

NSString *const ISButtonStyleNormal = @"ISButtonStyleNormal";
NSString *const ISButtonStylePrimary = @"ISButtonStylePrimary";
NSString *const ISButtonStyleDelete = @"ISButtonStyleDelete";


@implementation ISButtonTableViewCell

- (id)initWithStyle:(UIButtonStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:reuseIdentifier];
  if (self) {
    self.textLabel.textAlignment = NSTextAlignmentCenter;
  }
  return self;
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
  self.textLabel.text = configuration[ISFormTitle];
  NSString *style = configuration[ISFormStyle];
  if ([style isEqualToString:ISButtonStyleNormal]) {

  } else if ([style isEqualToString:ISButtonStylePrimary]) {
    self.backgroundColor = self.tintColor;
    self.textLabel.textColor = [UIColor whiteColor];
  } else if ([style isEqualToString:ISButtonStyleDelete]) {
    self.backgroundColor = [UIColor redColor];
    self.textLabel.textColor = [UIColor whiteColor];
  }
}


- (void)didSelectItem
{
  [self.settingsDelegate itemDidPerformAction:self];
}


@end
