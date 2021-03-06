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

#import "ISSwitchTableViewCell.h"
#import "ISForm.h"

@interface ISSwitchTableViewCell ()

@property (strong, nonatomic) NSString *identifier;

@end;

@implementation ISSwitchTableViewCell

+ (ISSwitchTableViewCell *)switchCell
{
  NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ISToolkit" withExtension:@"bundle"]];
  UINib *nib = [UINib nibWithNibName:@"ISSwitchTableViewCell"bundle:bundle];
  NSArray *objects = [nib instantiateWithOwner:nil options:nil];
  return objects[0];
}


+ (ISSwitchTableViewCell *) switchCellWithIdentifier:(NSString *)identifier
{
  ISSwitchTableViewCell *switchCell = [self switchCell];
  switchCell.identifier = identifier;
  return switchCell;
}


- (id) initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}


- (NSString *) reuseIdentifier
{
  return self.identifier;
}


- (void) enableSwitchValueChanged:(id)sender
{
  [self.delegate switchCell:self
               valueChanged:self.enableSwitch.on];
  [self.settingsDelegate item:self
               valueDidChange:@(self.enableSwitch.on)];
  if (self.action) {
    self.action(self.enableSwitch.on);
  }
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
  self.label.text = configuration[ISFormTitle];
}


- (void)setValue:(id)value
{
  self.enableSwitch.on = [value boolValue];
}


@end
