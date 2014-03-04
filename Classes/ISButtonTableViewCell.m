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

NSString *const ISButtonStyle = @"ISButtonStyle";
NSString *const ISButtonStyleDefault = @"ISButtonStyleDefault";
NSString *const ISButtonStyleDelete = @"ISButtonStyleDelete";


@implementation ISButtonTableViewCell

- (id)initWithStyle:(UIButtonStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.button = [[UIButton alloc] initWithFrame:self.contentView.bounds
                                            style:style];
    self.button.autoresizingMask
      = UIViewAutoresizingFlexibleWidth
      | UIViewAutoresizingFlexibleHeight;
    self.button.adjustsImageWhenDisabled = YES;
    [self.contentView addSubview:self.button];
    
    [self.button addTarget:self
                    action:@selector(buttonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}


- (void)buttonClicked:(id)sender
{
  [self.settingsDelegate itemDidPerformAction:self];
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
  [self.button setTitle:configuration[ISFormTitle]
               forState:UIControlStateNormal];
  NSString *type = configuration[ISButtonStyle];
  if ([type isEqualToString:ISButtonStyleDefault]) {
    self.button.style = UIButtonStyleDefault;
  } else if ([type isEqualToString:ISButtonStyleDelete]) {
    self.button.style = UIButtonStyleDelete;
  }
}


- (void)setValue:(id)value
{
  
}


@end
